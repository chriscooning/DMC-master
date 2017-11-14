require 'sidekiq/web'
require 'sidetiq/web'

Sidekiq.configure_server do |config|
  config.redis = { namespace: 'redis:DMC_new' }
end

Sidekiq.configure_client do |config|
  config.redis = { namespace: 'redis:DMC_new' }
end

Sidekiq::Web.use Rack::Auth::Basic do |username, password|
  username == configatron.sidekiq.username && password == configatron.sidekiq.password
end