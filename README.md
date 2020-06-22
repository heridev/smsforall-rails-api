Smsparatodos.com api
====================

### Setup this project for development
1. clone the repository
```
git clone git@bitbucket.org:heridev/smsparatodos_api.git
```

2. Create your database
```
rails db:create
rails db:migrate
```

3. Export some variables:
```
export RAILS_MASTER_KEY=bb5ffbd20b7fb60b4f05932fb2189277
```
4. Run the server in one tab:
```
rails s
```

5. Run sidekiq in a separate tab
```
export RAILS_MASTER_KEY=bb5ffbd20b7fb60b4f05932fb2189277
bundle exec sidekiq
```

If you want to run the console remember to set first the ENV variable
```
export RAILS_MASTER_KEY=bb5ffbd20b7fb60b4f05932fb2189277
rails console
```

### Managing encrypted env credentials

```
Rails.application.secrets.secret_key_base
```

## Edit production and development environment credentials

### How to edit development values
1. Export the env variable:
```
export RAILS_MASTER_KEY=bb5ffbd20b7fb60b4f05932fb2189277
```
2. Open the file with your editor:
```
EDITOR=nvim rails credentials:edit
```

### Steps to update production secret environment values

0. Set the ENV value key(take this value from the right production server):
```
export RAILS_MASTER_KEY=xxxxx
```

1. First, you need to rename the current development credentials in order to allow the edition of production files
and adding new values
```
mv config/credentials.yml.enc config/credentials_development.yml.enc 
mv config/master.key config/master_development.key 
```

2. Renaming production credentials so we can edit the production data:
```
mv config/credentials_production.yml.enc config/credentials.yml.enc
mv config/master_production.key config/master.key
```

3. And you should be able to edit that information:
```
EDITOR=nvim rails credentials:edit
```

4. After you are done with the credentials edition move back the production key
```
mv config/credentials.yml.enc config/credentials_production.yml.enc 
mv config/master.key config/master_production.key 
```

5. And the development move them back to its original names:
```
mv config/credentials_development.yml.enc config/credentials.yml.enc 
mv config/master_development.key config/master.key 
```

## Other commands when working with encrypted credentials

Checking production or development data in environment variables
```
# In order to see what kind of credentials we have in use in this moment
Rails.application.credentials[:type]

It seems like this two credentials are different
```
Rails.application.credentials[:secret_key_base]
# and
Rails.application.secrets.secret_key_base
```

So from now on, we will use always this one, as it is encrypted:
```
Rails.application.credentials.secret_key_base
# or using a hash key value
Rails.application.credentials[:secret_key_base]
```

If you want to check them using the current rails env
```
Rails.application.credentials.send(Rails.env)
```

## Generators
to generate Activejob classes:
```
bin/rails generate job sms_hubs_validation
```

For generating serializers:
```
rails g serializer Movie name year
```

## FCM and google cloud messaging in firebase
There are some plain examples about using the service in the following document
```
working_with_firebase_cloud_messaging.md
```

## Using translations

If you want to show a value based on a dynamic scope and value
```
I18n.t('dynamic_configuration', scope: 'page_size_configuration')
```

In the previous example, the locales in spanish look like this:
```
es:
  page_size_configuration:
    letter: 'carta'
    half-letter: 'media Carta'
```

If you want to format a date
```
I18n.localize current_date, format: :history_details
```


## When using POSTMAN for creating new users
using raw
```
{ "user": { "name": "heriberto perez", "email": "p@elh.mx", "password": "123qwe123" } }
```

"token_auth": "eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjozfQ.ArJ1yK_VcBsITp45C9RhAEBFcbvhHqb2GbkXl-uKrKU"

ENV['RAILS_MASTER_KEY']

Rails.application.credentials[:secret_key_base]

```
sms_content = I18n.t(
  'mobile_hub.content.welcome_msg',
  user_name: 'heriberto'
)
sms_confirmation_params = {
  sms_content: sms_content,
  sms_number: mobile_hub.device_number,
  sms_type: SmsNotification::STATUSES[:device_validation]
}

sms_notification = SmsNotification.create(sms_confirmation_params)

device_number = '3121698456'
sms_content = ""

SmsNotificationSenderService
```

