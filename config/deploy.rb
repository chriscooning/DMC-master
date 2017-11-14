require 'capistrano/ext/multistage'
require 'bundler/capistrano'
require 'capistrano/sidekiq'
require 'rollbar/capistrano'

set :stages, %w(staging production)
set :default_stage, "staging"
set :keep_releases, 5
set :scm, :git
set :rollbar_token, '#'

after   'deploy:setup', 'deploy:first'

before  'bundle:install',  'rbenv:create_version_file'

after   'deploy:finalize_update', 'db:create_symlink'
after   'deploy:create_symlink', 'deploy:cleanup'

#after   'deploy:migrate', 'db:migrate_data'