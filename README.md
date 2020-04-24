Smsparatodos.com api
====================



### Managing encrypted env credentials

Rails.application.secrets.secret_key_base

## Edit production and development environment credentials

## Steps to update production environment values

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
EDITOR=vim rails credentials:edit
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
```

If you want to check them using the current rails env
```
Rails.application.credentials.send(Rails.env)
```

