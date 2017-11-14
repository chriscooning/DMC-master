## Welcome to DigitalMediaCenter

Simple template for Rails 4 based projects

## Getting Started

* `$ git clone git://github.com/droidlabs/dmc_new.git myapp`
* `$ cd ./myapp`
* `$ cp config/database.yml.example config/database.yml`
* Configure your config/database.yml
* `$ bundle install`
* `$ rake db:setup`

## Deploy to staging

### Setup SSH Access
* `$ brew install ssh-copy-id`
* `$ ssh-copy-id username@hostname`

### First Server Setup
* configure config/deploy/staging.rb
* `$ cap deploy:setup`

### Usefull commands
* deploy with migrations:
* `$ cap deploy:migrations`
* connect via ssh
* `$ cap ssh`
* show application logs
* `$ cap log`
* start rails console
* `$ cap console`
* [see more](https://github.com/capistrano/capistrano/wiki/Capistrano-Tasks)

## Data migrations

* Generate data migration
* `$ rails g data_migration generate_user_tokens`

* Run data migration
* `$ rake data:migrate`

## Admin panel

**PLEASE DON'T FORGET TO CHANGE ADMIN PASSWORD**

* url: yoursite.com/admin
* username: admin@example.com
* password: password


## Running in dev mode with file upload capabilities

In order to run DMC in development mode and get upload capabilities, you have to get an external hostname for your local server:

`proxylocal 3000 --host <your-subdomain>`

`<your-subdomain>` - choose any subdomain you like otherwise proxylocal will generate the random one and it is not ver convenient

Then you can hit it the following ways:

The 'frontend' part:
`http://<dmc-subdomain>.<your-subdomain>.t.proxylocal.com/`

`<dmc-subdomain>` is a 'frontend' subdomain here which can be found at DMC 'My Account' page as 'Name' attribute (of course you can amend it).

The 'backend' part:

`http://<your-subdomain>.t.proxylocal.com/`

to access backend, your-subdomain should be ignored by Subdomain constraint ( lib/subdomain )
by default, there are only <dmc_wayne>


## Video processing provides heywatch service - http://heywatch.com 

The correct credentials are in configatron files corresponding to the current environment

