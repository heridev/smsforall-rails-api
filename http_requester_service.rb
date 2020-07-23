require 'uri'
require 'net/http'
require 'json'

class HttpRequesterService
  class << self
    def make(url, method, headers = {}, data = {})
      uri          = URI.parse(url)
      http         = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      request      = Net::HTTP.const_get(method).new(uri.request_uri)
      request.body = data.to_json if method == 'Post'

      # enable/disable according to your needs
      # http.verify_mode = OpenSSL::SSL::VERIFY_NONE

      set_headers request, headers
      http.request request
    end

    private
    def set_headers(request, headers = {})
      headers.each { |key, value| request[key] = value }
    end
  end
end

headers = {
  'Authorization-Token': 'Bearer eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjoxM30.1KX29F-3h6gJYsnntAQH08NWlEAD91utxoMh8J_sfaw',
  'Authorization-Client': '$2a$12$ZL6.AGqVM7QWZa80Olm/m.',
  'Content-Type': 'application/json'
}

10.times do |number|
  values = %i(juan pepe chuy heriberto andrea pako fabian roberto irvin chuy mary maria juanit alberto roberto luis eduardo eddie kevin cone alex rafa)
  body = {
    'sms_number': '+523121698456',
    'sms_content': "hola #{values.sample} como te va? - #{number} - #{Time.now.to_i}",
    'sms_customer_reference_id': "#{number} - #{Time.now.to_i}",
    'mobile_hub_id': '477989dc-b431-4e95-856c-7b616aaffef8',
    'sms_type': 'standard_delivery'
  }

  response = HttpRequesterService.make('https://smsparatodosapi.ngrok.io/v2/sms/create', 'Post', headers, body)
  puts response.read_body
end


