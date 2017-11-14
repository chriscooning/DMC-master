require 'capistrano-rbenv'

set :dns_name, "#"

set :application, "dmc_new"
set :repository,  "git@github.com:deepwater/DMC.git"

role :web, dns_name                          # Your HTTP server, Apache/etc
role :app, dns_name                          # This may be the same as your `Web` server
role :db,  dns_name, primary: true           # This is where Rails migrations will run

set :deploy_to, "/data/#{application}"

set :rails_env, 'production'
set :branch, 'production'
set :use_sudo, false

set :user, '#'
set :password, '#'
set :port, 22

set(:rbenv_ruby_version, '2.0.0-p353')