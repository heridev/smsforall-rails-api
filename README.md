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
3. Customize your env variables.
We are using the dotenv rails gem for easy management in development.
You need to rename the file `.env-development` into `.env` if you are using the terminal you can run
```
cp .env .env-development
``` 

And that file would look like this:
```
DEFAULT_MASTER_RECEIVER_PHONE_NUMBER="+52312169xxxx"
RAILS_MASTER_KEY=bb5ffbd20b7fb60b4f05932fb2189277
REDIS_URL="redis://localhost:6379/1"
SIDEKIQ_ADMIN_USER='sidekiq'
SIDEKIQ_ADMIN_PASSWORD='pass'
...
```
Make any customizations as needed, especially the `DEFAULT_MASTER_RECEIVER_PHONE_NUMBER` in the form of symbol `+` international code + 10 digits of your phone, for instance, for México is 52.

4. Make sure your Redis server is running in the default port:
```
redis://localhost:6379/1
```
5. Run the server
```
rails s -p 3030
```
At this point, you should see this:
![image](https://github.com/heridev/smsforall-rails-api/assets/1863670/3f920b9b-66bf-4b0b-814b-4524e8c3af98)
![image](https://github.com/heridev/smsforall-rails-api/assets/1863670/09acb82d-8cb0-4cba-9b49-5143800254bf)

### Rails console
If you want to run the console
```
rails console
```

### Visualize the Sidekiq panel and background jobs
If you want to access the Sidekiq panel, then you access the URL:
```
localhost:3030/panel/sidekiq
```

### Test suite
As of now on July 1st, 2020, we only have Rspec tests in place, if you want to run them, just do it as follows
```
export RAILS_MASTER_KEY=bb5ffbd20b7fb60b4f05932fb2189277
bundle exec rspec spec
```

## FCM and Google Cloud messaging in Firebase
Firebase Cloud Messaging (FCM) is a cross-platform messaging solution that lets you reliably send messages at no cost. Using FCM, you can notify a client app that new email or other data is available to sync.

FCM is an important aspect in the Architecture of smsforall.org, and it is the way that we can keep live communication with all our devices even if they get disconnected for a long period.

To keep configure properly the project, you might need to generate your credentials using the latest FCM V1 
https://firebase.google.com/docs/reference/fcm/rest/v1/projects.messages

All of this is handled already by the Android Native Application and the Ruby gem `fcm` has already been implemented.

All you need to do is create a project in the Google Cloud Console and then generate service account credentials that you will download in the form of a ``.json`` file and that you will use to include all those values into your encrypted values for either development or production.

In general, this is how they would look:

1. You visit the Firebase console at a link like this
https://console.firebase.google.com/u/0/
2. Create a new project in the `Add project` option and enter a name for both, production and development/staging environments.
3. Select the Google Analytics account(default) and click on the `create project` button.
4. After that you would be redirected to a project that would look like this
![image](https://github.com/heridev/smsforall-rails-api/assets/1863670/9b03bfbb-28dc-4892-ae30-90944cf448c0)
5. As you see in the image, there is an Android option that you might need to click and create a connection for your Android Application
![image](https://github.com/heridev/smsforall-rails-api/assets/1863670/dfb2703c-8895-4d4a-a67e-0d28d1be9416)
6. Download your Google credentials.json(and you will need to place this file in the Android Application app folder with the following name, eg: app/google-services.json)
![image](https://github.com/heridev/smsforall-rails-api/assets/1863670/45f806bc-6214-4f9c-87e7-f5e608c79a87)
NOTE: Once you are ready with your credentials you can continue reading on how to generate your APK so you can install it on your device by following the rest of the instructions in the [Android application repository](https://github.com/heridev/sms-mobile-hub)

### The next part of the configuration is about the SDK and the backend server we can use to send messages to your Android phone.

7. Then you will see some instructions on how to use it in your Android Application(it's already set in the Android Application), so you can click `Next`
8. Click on `continue to console`
9. The next thing is to be able to send messages to your devices using one of the SDKs available, in this case, we are using Ruby and the `fcm` gem, so let's continue with the rest of the configuration by clicking on the Cloud messaging option or directly in this URL(remember to include the right name of your project in the URL)
https://console.firebase.google.com/u/0/project/here-is-the-name-of-your-project/messaging/onboarding
10. Let's follow this tutorial as of December 2023 on how to generate your SDK credentials to interact with your mobile
https://docs.google.com/document/d/1OxKC7t2ND_4gCAJnGGmlKazMLcr3mtCrGeUUNckrRuw/edit#heading=h.mze0256cepto
11. If you followed all the steps correctly, at this point you might have a `.json` file downloaded in your machine, and the next thing to do is to encrypt those values and make them available to your Rails API by following the instructions mentioned in the following section about encrypted env credentials:

### Configure the FCM messaging in your development machine
1. Export the env variable:
```
export RAILS_MASTER_KEY=bb5ffbd20b7fb60b4f05932fb2189277
```
2. Open the file with your editor:
```
EDITOR=nvim rails credentials:edit
```
You will need to open the `.json` with your credentials in an editor or you can display them in the terminal, as you will need to copy manually from there some values and include them in the encrypted credentials that your `EDITOR` just opened in the previous step 

## How do you generate your encrypted credentials for the production environment?
Let's say you already tested everything locally and you want to deploy that into staging/production, how do you securely store your final credentials?

1. You can rename the current development encrypted values, by renaming the current file:
```
mv config/credentials.yml.enc config/credentials_development.yml.enc 
```
2. Generate a Rails Master Key that you can store safely, for this, you can use the Rails secret task
```
smsforall-rails-api heridev$ bundle exec rails secret | cut -c-32
34c3f8ce3e13ba493809841b535f5dc0
```
3. Store that in a secure place
4. Export it to begin with the encryption process
```
export RAILS_MASTER_KEY=34c3f8ce3e13ba493809841b535f5dc0
```
5. Run the edition of your credentials
```
EDITOR=nvim rails credentials:edit
```
Once you do that, by default you will see a template like this:
```
# aws:
#   access_key_id: 123
#   secret_access_key: 345

# Used as the base secret for all MessageVerifiers in Rails, including the one protecting cookies.
secret_key_base: 8fd0183188c3466561d8xxxxxxxxx
```
keep only the `secret_key_base` value and include the following template for the Firebase Credentials that you will need to provide later on
```
type: 'production'
# Used as the base secret for all MessageVerifiers in Rails, including the one protecting cookies.
secret_key_base: 8fd0183188c3466561d8xxxxxxxxx
google_firebase:
  - type: "service_account"
  - project_id: ""
  - private_key_id: ""
  - private_key: "-----BEGIN RSA PRIVATE KEY-----.....PRIVATE KEY-----\n"
  - client_email: "service-account-xxx@sms-xxxxxxx.iam.gserviceaccount.com"
  - client_id: "xxxxxxxx"
  - auth_uri: "https://accounts.google.com/o/oauth2/auth"
  - token_uri: "https://oauth2.googleapis.com/token"
  - auth_provider_x509_cert_url: "https://www.googleapis.com/oauth2/v1/certs"
  - client_x509_cert_url: "xxxxx"
  - universe_domain: "googleapis.com"
```

and exit the editor in my case vim with the following keystrokes esc :x

The previous step was to create your Firebase application and the service account `credentials.json` file(FCM V1 endpoint) so you should be able to provide those values based on that `.json` file

NOTE: once you are done with the final credentials, remember to rename this file from:
```
config/credentials.yml.enc
```
to
```
config/credentials_production.yml.enc
```

Please include it in your next commit, so it can be used once you deploy your application to your preferred hosting provider(e.g. Heroku)

### Managing encrypted env credentials

```
Rails.application.secrets.secret_key_base
```

### Steps to update production secret environment values

0. Set the ENV value key(take this value from the right production server):
```
export RAILS_MASTER_KEY=xxxxx
```

1. First, you need to rename the current development credentials to allow the edition of production files
and adding new values
```
mv config/credentials.yml.enc config/credentials_development.yml.enc 
```

2. Renaming production credentials so we can edit the production data:
```
mv config/credentials_production.yml.enc config/credentials.yml.enc
```

3. And you should be able to edit that information:
```
EDITOR=nvim rails credentials:edit
```

4. After you are done with the credentials edition move back the production key
```
mv config/credentials.yml.enc config/credentials_production.yml.enc 
```

5. And the development move it back to its original name:
```
mv config/credentials_development.yml.enc config/credentials.yml.enc 
```

### Connecting [Android](https://github.com/heridev/sms-mobile-hub), app.smsforall.org in local
Eventually, if you want to modify the different pieces in the system(Android, React App, and API), you will need to connect all the pieces locally for development, and for that you might need to expose your local API so the Android client and React Client Application can connect with the API, so to achieve that, the simplest approach is to use `Ngrok` with the free plan that allows you to claim a static subdomain that won't change all the time, so you don't need to keep updating the allowed hosts all the time for your Rails API server if you want to begin using Ngrok.

1. You need to register a free account on the official website [ngrok](https://ngrok.com/) or directly in the [signup page](https://dashboard.ngrok.com/signup)

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

6. Run your [React app frontend](https://github.com/heridev/smsforall-react-app) yarn project and specify to use the right API backend URL in this case:
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
