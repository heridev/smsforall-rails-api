# frozen_string_literal: true

Rack::Attack.enabled = !Rails.env.test?

# 2 requests per second
# Rack::Attack.throttle('requests by ip', limit: 4, period: 2, &:ip)

class Rack::Attack
  # By default, Rack::Attack uses `Rails.cache` to store requests information.
  # as we are using config.cache_store we are using Redis
  class Request < ::Rack::Request
    # You may need to specify a method to fetch the correct remote IP address
    # if the web server is behind a load balancer.
    #
    # if we implement later cloudfare we can also include
    # this value env['HTTP_CF_CONNECTING_IP']
    def remote_ip
      @remote_ip ||= (env['action_dispatch.remote_ip'] || ip).to_s
    end

    def allowed_ip?
      find_whitelist_ips.include?(remote_ip)
    end

    # in some case it was raising this error
    # ActionDispatch::Http::Parameters::ParseError (no implicit conversion of nil into String)
    def get_body_params
      result = begin
                 JSON.parse(body.read)
               rescue StandardError
                 {}
               end
      body.rewind
      result
    end

    def find_whitelist_ips
      default_ips = '127.0.0.1, ::1'
      allow_ip_whitelist = ENV.fetch(
        'ALLOWED_IP_WHITELIST_RACK_ATTACK',
        default_ips
      )

      allow_ip_whitelist.split(',').map(&:strip)
    end
  end

  throttle(
    'limit logins per email',
    limit: 5,
    period: 1.minute
  ) do |request|
    post_params = request.get_body_params
    request.path == '/v1/user_sessions' &&
      request.post? &&
      post_params['email']
  end

  # Exponential backoff for all requests to root path
  #
  # Allows 240 requests in ~8 minutes
  #        480 requests in ~1 hour
  #        960 requests in ~8 hours (~2,880 requests/day)
  (3..5).each do |level|
    throttle(
      "req/ip/#{level}",
      limit: (30 * (2**level)),
      period: (0.9 * (8**level)).to_i.seconds
    ) do |req|
      req.remote_ip if req.path == '/'
    end
  end

  # if none of the previou rules apply let's add
  # a default one
  # Throttle all requests (120rpm/IP)
  throttle('req/ip', limit: 2, period: 1.second, &:remote_ip)

  # Do not throttle for allowed IPs
  safelist('allow from localhost', &:allowed_ip?)
end

# Logging blocked events
ActiveSupport::Notifications.subscribe('rack.attack') do |_name, _start, _finish, _request_id, payload|
  req = payload[:request]
  if req.env['rack.attack.match_type'] == :throttle
    request_headers = {
      'CF-RAY' => req.env['HTTP_CF_RAY'],
      'X-Amzn-Trace-Id' => req.env['HTTP_X_AMZN_TRACE_ID']
    }
    Rails.logger.info "[Rack::Attack][Blocked] remote_ip: \"#{req.remote_ip}\", path: \"#{req.path}\", headers: #{request_headers.inspect}"
  end
end
