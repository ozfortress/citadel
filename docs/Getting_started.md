# Getting started

1. [Installation](Getting_started.md)
2. [Database setup and management](Database.md)
3. [Getting initial admin priveleges](Privileges.md)
4. Customization

## Installation

In this tutorial Debian-like system will be used as a reference. The commands may vary if you have different OS or a different package manager. 

First of all, start with installing  all the dependencies:

`sudo apt-get update`
  

* Getting Ruby dependencies:

```
sudo apt-get install git-core curl zlib1g-dev build-essential libssl-dev libreadline-dev libyaml-dev libsqlite3-dev sqlite3
libxml2-dev libxslt1-dev libcurl4-openssl-dev python-software-properties libffi-dev nodejs
```

* Getting [rvm](https://rvm.io/) and Ruby 2.4.1:

```
sudo apt-get install libgdbm-dev libncurses5-dev automake libtool bison libffi-dev
gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
curl -sSL https://get.rvm.io | bash -s stable
source ~/.rvm/scripts/rvm
rvm install 2.4.1
rvm use 2.4.1 --default
ruby -v
```

* And, finally, installing Bundler:

`gem install bundler`

Bundler is a Ruby application's gem dependencies manager. The gemfile contains all the gems that we need to run our application. We can now install them with `bundle install` command.

Check if we have Rails ready to use:

`rails -v`


If everything works right, you'll see your current Rails version printed in your console.


