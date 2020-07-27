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

# locahost
# headers = {
#   'Authorization-Token': 'Bearer eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjoxM30.1KX29F-3h6gJYsnntAQH08NWlEAD91utxoMh8J_sfaw',
#   'Authorization-Client': '$2a$12$ZL6.AGqVM7QWZa80Olm/m.',
#   'Content-Type': 'application/json'
# }

# production
headers = {
  'Authorization-Token': 'eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjozfQ.S7-mMxhL76vwmDEHiBoC25b6OKWCGFfROZvUeaUHFoo',
  'Authorization-Client': '$2a$12$Spip/ZntEXFlgcjlB3Y4Ge',
  'Content-Type': 'application/json'
}

tablecast_number = '+523121698456'
xiaomi_rosa_number = '+523121231639'
personal_number = '+523121231517'

200.times do |number|
  sleep 0.5
  values = %i(juan pepe chuy heriberto andrea pako fabian roberto irvin chuy mary maria juanit alberto roberto luis eduardo eddie kevin cone alex rafa)
  body = {
    # 'sms_number': tablecast_number,
    # 'sms_number': xiaomi_rosa_number,
    'sms_number': personal_number,
    # invalid number
    # 'sms_number': '+5231212315',
    'sms_content': "hola #{values.sample} andas por alli? - #{number} - #{Time.now.to_i}",
    'sms_customer_reference_id': "#{number} - #{Time.now.to_i}",
    # locahost
    # 'mobile_hub_id': '31b819ef-37bd-4ecc-bae4-bc2dd52dfb58',
    # api.smsparatodos.com
    'mobile_hub_id': '49b04bad-30f7-4dd5-a9b1-ab90939e0f93',
    'sms_type': 'standard_delivery'
  }

  # localhost
  # response = HttpRequesterService.make('https://smsparatodosapi.ngrok.io/v2/sms/create', 'Post', headers, body)
  # production
  response = HttpRequesterService.make('https://api.smsparatodos.com/v2/sms/create', 'Post', headers, body)
  puts response.code
  puts response.read_body
end
