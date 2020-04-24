
My international number
523121231517


String phnNumber="+91"+editText.getText().toString();


### tutorial perron listito para copy-paste y callbacks chingones
https://mobiforge.com/design-development/sms-messaging-android

### listening to android firebase messages and intercept them
remember to install the firebase-messaging dependency

Using FCM - firebase cloud messaging
https://www.youtube.com/watch?v=KTQ4d3ZUS8g

fcm.googleapis.com/fcm/send
with authorization key
and
- to
- notification

official android tutorial
https://firebase.google.com/docs/cloud-messaging/android/client

### sending to specific users example with node
https://www.youtube.com/watch?v=c66gQzNNHuA

### Ruby bindings for fcm
https://github.com/spacialdb/fcm

server_key = "AAAANAwvztM:APA91bFyxNj6nmPN9C28GVK8BuvNFea6vDpC5g86GnprIt8ukAUOzSHHz013vL6gQdiwl8rlVrxpu9192hh7In8OnKbrfIfxPQMxxZcCa56BaCmxMa0wQC21uyWClXGIZTLtMEsP1M_J"
fcm_service = FCM.new(server_key, timeout: 3)

registration_ids= ["fAuo61x6Q7qRVc_30o4y5u:APA91bFcftyGzR713o_dknqbfdzPjLmLVwluejZGbFQNw9pEf6LawCn5vlfEVOv0KVAfWGaoJZYkNKVpXNITwUqzlqf09R8lfgh-Yqj5pbFezRYSFg2zxwshluPOZkV-ilRWrtgaAeme"]


invalid_ids= ["fAuo61x6Q7qRVc_30o4y5u:APA91bFcftyGzR713o_dknqbfdzPjLmLVwluejZGbFQNw9pEf6LawCn5vlfEVOv0KVAfWGaoJZYkNKVpXNITwUqzlqf09R8lfgh-Yqj5pbFezRYSFg2zxwshluPOZkV-ilRWrtgaAemedds"]


options = {
  "data": {
    "cellphone_number": "+523121231517",
    "sms_content": "Hola Heriberto, gracias por registrarte en Pacientes Web en breve le enviamos los datos de acceso.."
  }
}

options = {
  "data": {
    "cellphone_number": "+523121770155",
    "sms_content": "que onda pair.."
  }
}

options = {
  "data": {
    "cellphone_number": "+523121698456",
    "sms_content": "Hola sms para todos solo probando para ver cuando aguanta esto de los mensajes y si me deja envia una carta interminable jajaja, doble texto goes here.."
  }
}


Tablet para pacientes web demos y mas - sms para todos

100.times do |index|
  options = {
    "data": {
      "cellphone_number": "+523121698456",
      "sms_content": "mensajes para tu tablet # #{index + 1} - #{Time.zone.now.to_s}"
    }
  }
  response = fcm_service.send(registration_ids, options)
  body_response = JSON.parse(response[:body], symbolize_names: true)
  puts "valid #{index+1} "if body_response[:success] == 1
end

Mi numero personal

40.times do |index|
  options = {
    "data": {
      "cellphone_number": "+523121231517",
      "sms_content": "Hola sms no A #{index + 1} - #{Time.zone.now.to_s}"
    }
  }
  response = fcm_service.send(registration_ids, options)
  body_response = JSON.parse(response[:body], symbolize_names: true)
  puts "valid B #{index+1} "if body_response[:success] == 1
end

Jose pablo peralta
40.times do |index|
  options = {
    "data": {
      "cellphone_number": "+523121708994",
      "sms_content": "Sms para todos No. #{index + 1} - #{Time.zone.now.to_s}"
    }
  }
  response = fcm_service.send(registration_ids, options)
  body_response = JSON.parse(response[:body], symbolize_names: true)
  puts "valid B #{index+1} "if body_response[:success] == 1
end

smsparatodos@gmail.com/$m$paratodo$2020


So 30 messages in 30 minutes, so that means we can send 29 messages in a span of 30 minutes to avoid that warning jaja

### Steps to remove the limit
```
adb -s your-devices-id shell eg: adb -s caea45skeukftcau shell
settings put global sms_outgoing_check_interval_ms 900000 # to check every 15 minutes
settings put global sms_outgoing_check_max_count 200 # we allowed a maximum of 40 emails every 15 minutes
```


response = fcm_service.send(registration_ids, options)

invalid_response = fcm_service.send(invalid_ids, options)

JSON.parse(invalid_response, symbolize_names: true)

To format individual objects
```
body_response = JSON.parse(invalid_response[:body], symbolize_names: true)
body_response = JSON.parse(response[:body], symbolize_names: true)

if body_response[:success] == 1
  # the value was sent correctly
else
  # the devise is not available in this moment
  # maybe we need to send an alert for that.
end
```



response = fcm.send(registration_ids, options)

response = fcm.send(registration_ids, {data: {message: "message 1"}})

response = fcm.send(registration_ids, data: {message: "some message"})


New xiaomi token for firebase

Nuevo
fAuo61x6Q7qRVc_30o4y5u:APA91bFcftyGzR713o_dknqbfdzPjLmLVwluejZGbFQNw9pEf6LawCn5vlfEVOv0KVAfWGaoJZYkNKVpXNITwUqzlqf09R8lfgh-Yqj5pbFezRYSFg2zxwshluPOZkV-ilRWrtgaAeme

