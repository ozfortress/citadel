# Getting started

1. [Installation](Getting_started.md)
2. [Database setup and management](Database.md)
3. [Getting initial admin priveleges](Privileges.md)
4. Customization


## Database setup and management. 


Citadel is using PostgreSQL as a database, we're going to add a new repository to install a recent version of Postgres easily.

```
sudo sh -c "echo 'deb http://apt.postgresql.org/pub/repos/apt/ xenial-pgdg main' > /etc/apt/sources.list.d/pgdg.list"
wget --quiet -O - http://apt.postgresql.org/pub/repos/apt/ACCC4CF8.asc | sudo apt-key add -
sudo apt-get update
sudo apt-get install postgresql-common
sudo apt-get install postgresql-9.5 libpq-dev
```

* Access psql console:

`sudo -u postgres psql`

* Create a user to give your application an access to the database:

```psql
CREATE USER citadel_dev WITH password 'foobar';```

We are going to use 3 databases for development, test and producion enviroments, thus we need to create them first, and then grant `citadel_dev`  permissions to manage those databases:

```psql
CREATE DATABASE citadel_0;
CREATE DATABASE citadel_1;
CREATE DATABASE citadel_2;
GRANT ALL ON DATABASE citadel_0 TO citadel_dev;
GRANT ALL ON DATABASE citadel_1 TO citadel_dev;
GRANT ALL ON DATABASE citadel_2 TO citadel_dev;
```


Now we need to point our application to the PostgreSQL server. Open your `/config/database.yml` and fill it in using the example below. Use the actual server address instead of "localhost" if you did set it up on a remove server:

```yml
default: &default
  adapter: postgresql
  encoding: utf-8
  pool: 5
  username: citadel_dev
  password: foobar
  host: localhost
  port: 5432

development:
  <<: *default
  database: citadel_0

test:
  <<: *default
  database: citadel_1

production:
  <<: *default
  database: citadel_2

```

Once we are done with this, we are free to load out database schema to the server:

`rake db:schema:load`

Don't forget to fill in your Steam API key in `/config/secrets.local.yml` (there is an example file, you can simply copy and rename it and then change the API key to yours.

`secret_key_base` is used to generate cookies. Changing it after you have users signed up will reset their authorization.

We are now ready to run our application:

`rails s`

You can now open your browser and visit our application served locally.




