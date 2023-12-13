Rails Backend API for https://api.smsforall.org
====================

### How to run the project in development?
1. clone the repository
```
git clone git@github.com:heridev/smsforall-rails-api.git
```

2. Create your database
```
rails db:create
rails db:migrate
```
4. Run the server by copying, editing the default master receiver, and pasting in a new terminal.
```
# your phone number in the form of symbol `+` international code + 10 digits of your phone
# for instance, for México is 52
export DEFAULT_MASTER_RECEIVER_PHONE_NUMBER="+52312169xxxx"
export RAILS_MASTER_KEY=bb5ffbd20b7fb60b4f05932fb2189277
export REDIS_URL="redis://localhost:6379/1"
rails s -p 3030
```
At this point, you should see this:
![image](https://github.com/heridev/smsforall-rails-api/assets/1863670/3f920b9b-66bf-4b0b-814b-4524e8c3af98)
![image](https://github.com/heridev/smsforall-rails-api/assets/1863670/09acb82d-8cb0-4cba-9b49-5143800254bf)

### Rails console
If you want to run the console remember to set first the ENV variable
```
export RAILS_MASTER_KEY=bb5ffbd20b7fb60b4f05932fb2189277
export REDIS_URL="redis://localhost:6379/1"
rails console
```

### Visualize the Sidekiq panel and background jobs
If you want to access the Sidekiq panel remember to run the env variables as follows:
NOTE: Remember to stop and start your server again.
```
export SIDEKIQ_ADMIN_USER='sidekiq'
export SIDEKIQ_ADMIN_PASSWORD='pass'
```

Then you access the URL
```
localhost:3030/panel/sidekiq
```

### Connecting [Android](https://github.com/heridev/sms-mobile-hub), app.smsforall.org in local
Eventually, if you want to modify the different pieces in the system(Android, React App and API), you will need to connect all the pieces locally for development and for that you might need to expose your local API so the Android client and React Client Application are able to connect with the API, so in order to achieve that, the simplest approach is to use `Ngrok` with the free plan that allows you to claim a static subdomain that won't change all the time, so you don't need to keep updating the allowed hosts all the time for your Rails API server, if you want to begin using Ngrok.

1. You need to register a free account in the official website [ngrok](https://ngrok.com/) or directly in the [signup page](https://dashboard.ngrok.com/signup)

2. Request your static domain that would look like this:
![image](https://github.com/heridev/smsforall-rails-api/assets/1863670/6da6948c-ff82-4014-a541-e62551cc74ee)

3. Add your static domain to the following configuration file `config/environments/development.rb`
```
config.hosts << 'quick-xxxx-xxxxx.ngrok-free.app'
```

4. Run your server following the previous section in this README.md file
5. Run ngrok with the right subdomain(make sure your ngrok executable was downloaded successfully from [https://ngrok.com/download](https://ngrok.com/download))
```
ngrok http --domain=quick-xxxx-xxxx.ngrok-free.app 3030
```

6. Run your [React app frontend](https://github.com/heridev/smsforall-react-app) yarn project and specify to use the right API backend url in this case:
```
export REACT_APP_API_URL=https://quick-xxx-xxxxxx.ngrok-free.app
// and
yarn start
```

7. In your [Android project](https://github.com/heridev/sms-mobile-hub) before generating the version and installing it, make sure you have the right URL, for that:

- a). Open the file `grade.properties` 
- b). replace the value
```
BASE_URL_PRODUCTION="https://api.smsparatodos.com/"
```

with 
```
https://quick-xxxx-xxxx.ngrok-free.app
```
- c). Select the build variants as `prodDebug`
![image](https://github.com/heridev/smsforall-rails-api/assets/1863670/900f6aa3-ee56-49c6-87da-be2b2f3abd46)

- d). Run the app and install it on your device
- e). Begin with the coding and experimentation!

### Test suite
As of now on July 1st, 2020, we only have Rspec tests in place, if you want to run them, just do it as follow
```
export RAILS_MASTER_KEY=bb5ffbd20b7fb60b4f05932fb2189277
bundle exec rspec spec
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
# To see what kind of credentials we have in use at this moment
Rails.application.credentials[:type]
```

It seems like these two credentials are different
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

## FCM and Google Cloud messaging in Firebase
There are some plain examples of using the service in the following document
```
working_with_firebase_cloud_messaging.md
```

## Using translations

If you want to show a value based on a dynamic scope and value
```
I18n.t('dynamic_configuration', scope: 'page_size_configuration')
```

In the previous example, the locales in Spanish look like this:
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
"token_auth": "eyJhbGciOiJIUzI1xxxxx2lkIjozfQ.ArJ1yK_VcBsITxxxxxbvhHqb2GbkXl-uKrKU"
ENV['RAILS_MASTER_KEY']
Rails.application.credentials[:secret_key_base]

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

device_number = '312169xxxxx'
sms_content = ""

SmsNotificationSenderService
```

### Recurrent jobs - cron jobs
We are using the gem:
```
sidekiq-scheduler
```

That mimics the cron utility so we can enqueued scheduled jobs.

If you want to add a new cron schedule job open the file
```
config/sidekiq.yml
```

and most of the configuration regarding this gem is included in the 
```
config/initializers/sidekiq.rb
```

with:
```
SidekiqScheduler::Scheduler.instance.rufus_scheduler_options = {
  max_work_threads: max_work_threads
}
```
