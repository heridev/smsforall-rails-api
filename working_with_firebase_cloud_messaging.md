### Tutorial perron listito para copy-paste y callbacks chingones
https://mobiforge.com/design-development/sms-messaging-android

### listening to android firebase messages and intercept them
remember to install the firebase-messaging dependency

### Using FCM - firebase cloud messaging
https://www.youtube.com/watch?v=KTQ4d3ZUS8g

fcm.googleapis.com/fcm/send
with authorization key and
- to
- notification

official android tutorial
https://firebase.google.com/docs/cloud-messaging/android/client

### sending to specific users example with node
https://www.youtube.com/watch?v=c66gQzNNHuA

### Ruby bindings for fcm
https://github.com/spacialdb/fcm

### Numeros de celulares a hacer las pruebas correspondientes
- Jose pablo peralta -> "+523121428022"
- smsparatodos tablet -> +523121698456

So 30 messages in 30 minutes, so that means we can send 29 messages in a span of 30 minutes to avoid that warning jaja

### Steps to remove the limit
```
adb -s your-devices-id shell eg: adb -s caea45skeukftcau shell
settings put global sms_outgoing_check_interval_ms 900000 # to check every 15 minutes
settings put global sms_outgoing_check_max_count 200 # we allowed a maximum of 40 emails every 15 minutes
```

### Mas reciente codigo tecnico
for development you need the env variable
```
export RAILS_MASTER_KEY=bb5ffbd20b7fb60b4f05932fb2189277
rails console
devise_firebase_token = "eYzo1P8EQlSRJ3U6Y76OSR:APA91bHs0a9msnJFbh5uD1W1d2AZ1TZJ3GRPtIw4Ou0pxIAgdJ1BkyKjwqOA5j_Jv8sJEqnV_cqu_MGlvKI3g5r7zr815hQERAFmcJXRSCEfigH9ugSFDE8lXaoJJu3zTiDmLeKjxNS5"
phone_recipient_number = "+523121428022"
message_content = "Hola juan te confirmamos que tu cita fue agendada correctamente para el dia..."

params = {
  sms_content: message_content,
  sms_number: phone_recipient_number,
  sms_type: 'standard_delivery',
  sms_notification_id: sms_notification.unique_id || 'xxxxx-xxxx',
  device_token_firebase: devise_firebase_token
}
service = FirebaseMessagingService.new(params)
service.send_to_google!

## many times the same
29.times do
  service.send_to_google!
end
```
## Mas recient en marketing

### Next validations endpoint to control how many messages to send on the free plan
About this code there is a page in the PW notebook talking about this one

```
def find_hour_between_array
  current_time = Time.zone.now
  current_minute = current_time.strftime("%M").to_i
  current_hour = current_time.strftime("%H").to_i
  if current_minute >= 30
    next_hour = current_hour + 1
    start_time = current_time.change(hour: current_hour, min: 30)
    end_time = current_time.change(hour: next_hour)
    betweeen_hours_array = start_time, end_time
  else
    start_time = current_time.change(hour: current_hour)
    end_time = current_time.change(hour: current_hour, min: 30)
    betweeen_hours_array = start_time, end_time
  end

  betweeen_hours_array 
end

def find_next_try
  current_time = Time.zone.now
  current_minute = current_time.strftime("%M").to_i
  current_hour = current_time.strftime("%H").to_i
  if current_minute >= 30
    next_hour = current_hour + 1
    current_time.change(hour: next_hour, min: 1)
  else
    current_time.change(hour: current_hour, min: 30)
  end
end
```

## First checks to see if this user has send more than 1,000 in a day, we do not save them in free accounts

```
start_time = Time.zone.now.beginning_of_day
end_time = Time.zone.now.end_of_day

cache_key = "#{user_id}_#{start_time.to_i}_#{end_time.to_i}"

total_from_cache = count_from_cache = Rails.cache.fetch(cache_key)
if total_from_cache
  total_enqueued_today = total_from_cache
else
  total_enqueued_today = SmsNotification.where("sent_to_device_at >? and sent_to_device_at <?", start_time, end_time).count
end

if total_from_cache > 1000
  # we do not create new sms notifications
  # we send a sms alert and email to users and admins so
  # in case the the system is saturated we can disable accounts based on a value
  # and then we can call them so they know that we are monitoring our servers to
  # avoid breaking the server, we can also check from time to time, for spam
  return
end

count_from_cache = Rails.cache.fetch(*find_hour_between_array)
if count_from_cache
  how_many_processed = count_from_cache
else
  how_many_processed = SmsNotification.where("sent_to_device_at >? and sent_to_device_at <?", *find_hour_between_array).count
  save_in_cache_again
end

HALF_AN_HOUR_LIMIT_FOR_FREE_ACCOUNT = 25
if how_many_processed > HALF_AN_HOUR_LIMIT_FOR_FREE_ACCOUNT
  # we don't send it
  # this reschedule_for can be improve to make sure we are not rescheduling
  # many times, but we can start with it and then we can check if we
  # move it to the next 30 minutes block
  reschedule_for = current_time + 5.minutes
  sms_notification.update_columns(
    { was_rescheduled: true, scheduled_for: find_next_try }
  )
else
  SmsNotificationProcessor.new(sms_notification).send_to_device
end
```

```
class SmsNotificationProcessor
  attr_reader :sms_notification
  def initialize(sms_notification)
    @sms_notification = sms_notification
  end
  def send_to_device
    result = FCMService.send(sms_notification.message, sms_notification.number, device_token)
    if result
      sms_notification.mark_as_sent! # we update the `sent_to_device_at` and sent_by_device and update the status to 'delivered'
    else
      # here we are going to mark it as failure and we send an alert
      # in case there was an exception
    end
  end
end
```
```
class SmsNotificationCleaner
  def initialize(sms_notification)
    @sms_notification = sms_notification
  end
  def format_message_content
    # cleaning this one just in case there are more than 160 characters
  end
end
```

The history behind smsparatodos.com or smsforall.og
===================================================
Heriberto y Francisco Cardenas

Back in 2019 We needed to implement SMS for our business, including sending reminders, activation accounts, two factor authentication, etc

And looking into the current 

#### Que es Smsparatodos.com?
Hace unos meses atraz en nuestra plataforma para doctores Pacientes Web, necesitabamos implementar el envio de SMS para negocios, incluyendo, envio de confirmaciones de citas, recordatorios, authentication de usuarios, etc.
Pero despues de revisar nuestras opciones, no pudimos encontrar una opcion economica, ya que todos los precios de los proveedores ronda entre los 0.40 - $0.90, siendo uno de los mas caro una de las plataformas mas populares para desarrolladores (Twilio, Amazon, etc).
Pero despues de pensar y tratar de encontrar un proveedor que nos ofreciera un plan gratis para comenzar con el envio de SMS y alguna forma de validar nuestros negocios, nos dimos cuenta que esto no era posible con los proveedores actuales.
Ejemplo de proveedores en Mexico y Colombia
https://gist.github.com/heridev/ce49f2bf5bfa8753c1759bbe552b78cb

Fui alli cuando despues de analizarlo de forma profunda, nos dimos cuenta que muchos de los proveedores actuales ofrecen SMS ilimitados, y siendo que nuestros mensajes son personales (Son clientes nuestros), nosotros podemos enviar recordatorios manualmente de forma ilimitada, pero para que hacerlo manualmente cuando podemos automatizar las tareas.
Es alli donde nace smsparatodos.com, y empresas pequeñas de esta forma puede comenzar a utilizar el servicio de forma gratuita, con un envio de mensajes limitado de 40 sms por hora.
En caso de que necesita el envio de mas sms, es necesario contar con el plan profesional y seguir nuestras instrucciones al respecto.
De esta forma las pequeñas empresas puede comenzar al instante, solo es necesario contar con una dispositivo Android con conexion a internet todo el tiempo (o utilizando datos del mismo plan), y que se cuenta un con plan de SMS válido, asi como instalar nuestra aplicacion Android y registrar una cuenta en nuestra pagina web.
Parece muy bueno? pues lo es, esperemos que les sea de utilidad, y esperamos que puedas aprovechar esos SMS en tus negocios.


What is SMSforAll.org?

Hey Guys my Name is Heriberto Perez, I'm a senior software engineer at Genoa Telepsyquiatry but I'm also an entrepenur, and here is my story.
A few weeks ago, while working on a personal startup called pacientesweb.com(is kind of a EHR in MExico), I needed to send notifications via SMS text messages, which means sending appointment confirmations, reminders, sending some alerts to doctors, two factor authentication, etc, in other words sending SMS notifications just like any other bank application.
But after doing some research, I was not able to find a cheap, affordable and economic option, since all the prices are kind of expensive and more in Latinamerica, for eg, here in Mexico:
https://www.twilio.com/sms/pricing/mx
Twilio: $1.01 MXN or 0.0490 USD per message
And kind of the same from Amazon and other well known providers.
Indeed, they don't offer any free plan, so this is not good for small startups that only send a few notifications during the day.
Here is when I realized some interesting facts such as:

All Carrier brands such as:
In USA
- AT&T
- Sprint
- T-Mobile

In Mexico:
- Movistar
- Telcel

Offer "personal" unlimited SMS messages in their plans.
USA and some latin american countries:
https://gist.github.com/heridev/ce49f2bf5bfa8753c1759bbe552b78cb

So, after that analysis, you can see that they mention that you have the ability to send UNLIMITED personal messages so, that means that anybody can send reminders, notifications and other kind of campaigns by sending them manually to all their customers, in my case would be to doctors and patients but then after doing that, you might have the following questions:
- Why should I do it manually and how long would it take me to send an SMS reminder to all of my 50 patients everyday?
- Can we automate this task?

After making those questions, smsforall.org or in spanish smsparatodos.com were borned.
My missing is to help small startups and offer to them a free plan to send SMS messages without little to no intervention, with only one restriction and this one is a limit allow sending only 40 SMS per hour or 20 SMS every 30 minutes.
And in the case that you need to send more SMS messages, you will be required to upgrade to the paid plan and after following some technical instructions and videos you would be able to start sending unlimited SMS at a reeeealy low prices or fixed monthly fee.
In this way, small companies can start sending SMS messages in their platforms right away with no initial cost.
When is it going to be fully available?
Good question my friend, that is where you as a patron can help me speeding this development, as in this moment I'm just working on this amazing project in my spare time (8 hours a week), but I have a plenty of work ahead.

In my blog post, available to all my patreon, I'll be sharing the architecture and in the second one sharing the ROADMAP and my current progress on the entire architecture.
I'll be sharing some videos to you as well.
After that you will have a sense of when this can be finished, if you are excited just like the way I'm, you will become my patreon :)
Should we make this an open source software in the future? Well, who knows, in the meantime.
That's it, have a nice day and be happy.
Heriberto

### Second blog post:

How can I use smsforall.org?

You basically need:
- Register an account in smsforall.org
- To install our Android application
- Keep your Android phone connected to internet
- Having a valid phone plan.

Does it look great? Well, it is, hopefully it will be useful to you and we hope you can take advantage of those SMS in your business.

Smsforall.org

