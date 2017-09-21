# Getting started

## Installation

In this tutorial Debian-like system will be used as a reference. The commands may vary if you have different OS or a different package manager.

First of all, start with installing  all the dependencies:

 - Installing Ruby dependencies:
`sudo apt-get update`
Getting Ruby dependencies
`sudo apt-get install git-core curl zlib1g-dev build-essential libssl-dev libreadline-dev libyaml-dev libsqlite3-dev sqlite3 libxml2-dev libxslt1-dev libcurl4-openssl-dev python-software-properties libffi-dev nodejs`

- Getting [rvm](https://rvm.io/) and Ruby 2.4.1:
```sudo apt-get install libgdbm-dev libncurses5-dev automake libtool bison libffi-dev
gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
curl -sSL https://get.rvm.io | bash -s stable
source ~/.rvm/scripts/rvm
rvm install 2.4.1
rvm use 2.4.1 --default
ruby -v```

- And, finally, installing Bundler:
`gem install bundler`

- Now we can procceed to Rails installation: 
 ```gem install rails -v 5.1.3
 rails -v```

- Citadel uses PostgreSQL as a database, we're going to add a new repository to easily install a recent version of Postgres.
```sudo sh -c "echo 'deb http://apt.postgresql.org/pub/repos/apt/ xenial-pgdg main' > /etc/apt/sources.list.d/pgdg.list"
wget --quiet -O - http://apt.postgresql.org/pub/repos/apt/ACCC4CF8.asc | sudo apt-key add -
sudo apt-get update
sudo apt-get install postgresql-common
sudo apt-get install postgresql-9.5 libpq-dev```

Access psql console:

`sudo -u postgres psql`

Create a user to give your application an access to the database:

`CREATE USER citadel_dev WITH password 'foobar';`

We are going to use 3 databases for development, test and producion enviroments, thus we need to create them first, and then grant `citadel_dev`  permissions to manage those databases:

```CREATE DATABASE citadel_0;
CREATE DATABASE citadel_1;
CREATE DATABASE citadel_2;
GRANT ALL ON DATABASE citadel_0 TO citadel_dev;
GRANT ALL ON DATABASE citadel_1 TO citadel_dev;
GRANT ALL ON DATABASE citadel_2 TO citadel_dev;```

