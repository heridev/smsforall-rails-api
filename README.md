Smsparatodos.com api
====================


### Managing encrypted env credentials

```
Rails.application.secrets.secret_key_base
```

## Edit production and development environment credentials

### How to edit development values
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
```
{ "user": { "name": "heriberto perez", "email": "p@elh.mx", "password": "123qwe123" } }
```

user = 

for heroku staging
ENV['RAILS_MASTER_KEY']

for production
```
6ff2e0c84d197349c3abd418444884a186f8169d47af1bc52fea54554a250fe6073a13d934a4eb6a368f68761ec7dcfcf57388a8da1e3d6ef50dba4da75aacd7
```
Rails.application.credentials[:secret_key_base]


export RAILS_MASTER_KEY=612928079afc9957c0e4fbe7f797951c

development
```
export RAILS_MASTER_KEY=bb5ffbd20b7fb60b4f05932fb2189277
```

secret_key_base
6ff2e0c84d197349c3abd418444884a186f8169d47af1bc52fea54554a250fe6073a13d934a4eb6a368f68761ec7dcfcf57388a8da1e3d6ef50dba4da75aacd7

