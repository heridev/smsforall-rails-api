require 'net/http'

class HttpRequesterService
  class << self
    def make(url, method, headers = {}, data = {})
      uri          = URI.parse(url)
      http         = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      request      = Net::HTTP.const_get(method).new(uri.request_uri)
      request.body = data.to_json if method == 'Post'

      if development_or_test_env?
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      end

      set_headers request, headers
      http.request request
    end

    private

    def development_or_test_env?
      Rails.env.test? || Rails.env.development?
    end

    def set_headers(request, headers = {})
      headers.each { |key, value| request[key] = value }
    end
  end
end
