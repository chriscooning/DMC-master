source 'http://rubygems.org'

gem 'rails', '4.1.9'
gem 'pg', '0.18.1'
gem 'slim-rails', '2.1.5'
gem 'devise', '3.4.1'
gem 'configatron', '2.13.0'
gem 'navigation_link_to', '0.0.1'
gem 'cyrax', '0.5.2'
gem 'acts-as-taggable-on', '2.4.1'
gem 'heywatch', '~> 2.0.0'
# TODO: http://ruby.awsblog.com/post/TxFKSK2QJE6RPZ/Upcoming-Stable-Release-of-AWS-SDK-for-Ruby-Version-2
gem 'aws-sdk', '< 2.0'
gem 'kaminari', '0.16.3'
gem 'paranoia', '2.1.0'

gem 'paperclip', '4.2.1'

gem 'googl', '0.7.0'

gem 'simple_form', '3.1.0'
gem 'nested_form', '0.3.2'
gem 'activeadmin', github: 'activeadmin'

gem 'rack-ssl-enforcer', '0.2.8'

gem 'counter_culture', '~> 0.1.23' # Counter caching

# assets
gem 'sass-rails', '5.0.1'
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails', '~> 4.0.0'
# TODO: https://github.com/jashkenas/coffeescript/issues/3829
gem 'coffee-script-source', "~> 1.8.0"
gem 'therubyracer', platforms: :ruby
gem 'bootstrap-sass', '3.3.4.1'
gem 'jquery-rails', '3.1.2'
gem 'jquery-ui-rails', '5.0.3'
gem 'jquery-turbolinks', '2.0.1'
gem 'turbolinks', '2.5.3'

# Custom JS
gem 'sweet-alert' # Custom alerts
gem 'sweet-alert-confirm' # Override default Rails UJS confirms

gem 'redactorjs-rails', '9.1.4'
gem 'skim', '0.9.3'

gem 'sinatra', require: false
gem 'sidekiq', '3.3.2'
gem 'sidetiq', github: 'tobiassvn/sidetiq'

#stats
gem 'newrelic_rpm'

group :test, :development do
  gem 'byebug'
  gem 'proxylocal'
end

gem 'net-ssh', '2.7.0'
group :development do
  gem 'capistrano', '2.15.5', require: false
  gem 'capistrano-rbenv', require: false
  gem 'capistrano-sidekiq', require: false
  gem 'letter_opener', '1.3.0'
  gem 'spring'
  gem 'thin', '1.6.0'
  gem 'pry-rails'
  gem 'zeus', '0.13.3'
end

group :test do
  gem 'sqlite3'
  gem 'rspec-rails', '~> 2.14.0'
  gem 'shoulda', '3.5.0'
  gem 'database_cleaner', '1.0.1'
  gem 'factory_girl_rails', '4.2.1'
  gem 'capybara', '2.1.0'
  gem 'email_spec', '1.4.0'
  gem 'mocha', '0.14.0', require: 'mocha/setup'
  gem 'turnip'
  gem 'timecop'
end

group :production do
  gem 'rollbar'
end
