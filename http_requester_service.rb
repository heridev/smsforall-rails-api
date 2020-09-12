# frozen_string_literal: true

# locahost
require 'rails'
require_relative 'app/services/http_requester_service.rb'
headers = {
  'Authorization-Token': 'eyJhbGciOiJIUzI1NiJ9.eyJpZCI6NX0.zfjjmOGaDaIlEHsizuJ15_tSeaTxjNMWkwFaAXcTH7o',
  'Authorization-Client': '$2a$12$/qtvnY0kBQYD/u5Fz8vVN.',
  'Content-Type': 'application/json'
}

# production
# headers = {
#   'Authorization-Token': 'eyJhbGciOiJIUzI1NiJ9.eyJpZCI6MX0.O_9fM8kp377Le53w8JIiK13uOcknR_TlNuMA7_3xFTI',
#   'Authorization-Client': '$2a$12$3njEmKnVmyyts4aMJSHIjO',
#   'Content-Type': 'application/json'
# }

tablecast_number = '+523121698456'
xiaomi_rosa_number = '+523121231639'
personal_number = '+523121231517'

30.times do |number|
  # sleep 60

  phone_number = personal_number
  # phone_number = number.even? ? personal_number : xiaomi_rosa_number
  # phone_number = number.even? ? tablecast_number : xiaomi_rosa_number
  # phone_number = number.even? ? '312123151' : tablecast_number
  # phone_number = number.even? ? '312123151' : personal_number

  # sleep 10
  values = %i[juan pepe chuy heriberto andrea pako fabian roberto irvin chuy mary maria juanit alberto roberto luis eduardo eddie kevin cone alex rafa]
  current_time = Time.now.in_time_zone('America/Mexico_City').strftime('%a, %b %e %I:%M:%S %P')
  body = {
    'sms_number': phone_number,
    # 'sms_number': xiaomi_rosa_number,
    # 'sms_number': personal_number,
    # invalid number
    # 'sms_number': '+5231212315',
    'sms_content': "Ya casi termino #{values.sample} ##{number} el dia #{current_time}",
    'sms_customer_reference_id': "#{number} - #{Time.now.to_i}",
    # Locahost
    'mobile_hub_id': '31b819ef-37bd-4ecc-bae4-bc2dd52dfb58',
    # tablecast localhost
    # Production
    # 'mobile_hub_id': '71981a3f-a14a-4104-9031-b421baea29db',
    # my personal cel localhost
    # 'mobile_hub_id': 'ed02d4f6-6c56-46b6-9f01-1628db8e9aa3',
    'sms_type': 'standard_delivery'
  }

  # localhost
  response = HttpRequesterService.make('https://smsparatodosapi.ngrok.io/v2/sms/create', 'Post', headers, body)
  # production
  # response = HttpRequesterService.make('https://api.smsparatodos.com/v2/sms/create', 'Post', headers, body)
  puts response.code
  puts response.read_body
end

# contacts = [
#   {
#     name: 'tabletcast',
#     phone_number: xiaomi_rosa_number
#   },
#   {
#     name: 'tabletcast',
#     phone_number: '+523121698456'
#   },
#   {
#     name: 'Roger',
#     phone_number: '+524491298221'
#   },
#   {
#     name: 'Trino',
#     phone_number: '+523121078193'
#   },
#   {
#     name: 'vicmaster',
#     phone_number: '+523141980961'
#   },
#   {
#     name: 'Edwin',
#     phone_number: '+523121072187'
#   },
#   {
#     name: 'Omar Vazquez',
#     phone_number: '+524491791450'
#   },
#   {
#     name: 'Mumo',
#     phone_number: '+523121020899'
#   },
#   {
#     name: 'Sam Belmor',
#     phone_number: '+523121113267'
#   },
#   {
#     name: 'Daniel Haro',
#     phone_number: '+523121335582'
#   },
#   {
#     name: 'Andrea',
#     phone_number: '+523121708994'
#   },
#   {
#     name: 'Heriberto',
#     phone_number: '+523121231517'
#   }
# ]

# contacts = [
#   {
#     name: 'Alberto',
#     phone_number: '+523121231517'
#   },
#   {
#     name: 'Raul',
#     phone_number: '+523121231517'
#   },
#   {
#     name: 'Maria',
#     phone_number: '+523121231517'
#   },
#   {
#     name: 'Juan',
#     phone_number: '+523121231517'
#   },
#   {
#     name: 'Heriberto',
#     phone_number: '+523121231517'
#   }
# ]

# contacts = [
#   {
#     name: 'Alberto',
#     phone_number: '+523121231517'
#   }
# ]

# phrases = [
#   'sé impecable con tus palabras',
#   'No te tomes nada personal-mente',
#   'No hagas suposiciones',
#   'Y has siempre tu máximo esfuerzo',
#   '---------Que la paz este contigo--------'
# ]
#
# phrases = [
#   'sé impecable con tus palabras'
# ]

# phrases.each_with_index do |phrase, index|
#   contacts.each do |contact|
#     sms_content = if index.zero?
#                     "#{contact[:name]} #{phrase}"
#                   else
#                     phrase
#                   end
#
#     body = {
#       'sms_number': contact[:phone_number],
#       'sms_content': sms_content,
#       'sms_customer_reference_id': contact[:phone_number],
#       'mobile_hub_id': 'a4a64d1b-02b0-4d72-ad2e-6196d1f64fd3',
#       'sms_type': 'standard_delivery'
#     }
#     response = HttpRequesterService.make(
#       'https://smsparatodosapi.ngrok.io/v2/sms/create',
#       'Post',
#       headers,
#       body
#     )
#     puts response.code
#     puts response.read_body
#   end
# end
