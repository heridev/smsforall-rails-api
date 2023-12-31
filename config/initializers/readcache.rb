# frozen_string_literal: true

module ReadCache
  class << self
    def redis
      @redis ||= Redis.new(
        url: ENV.fetch('REDIS_URL'),
        ssl_params: { verify_mode: OpenSSL::SSL::VERIFY_NONE }
      )
    end
  end
end
