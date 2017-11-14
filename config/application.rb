require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(:default, Rails.env)

module DigitalMediaCenter
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
    config.autoload_paths += %W(#{Rails.root}/app/DMC/**/*)
    config.autoload_paths += %W(#{config.root}/lib)

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Moscow'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :ru

    # Enable the asset pipeline
    config.assets.enabled = true
    config.assets.paths << "#{Rails.root}/app/assets/fonts"
    # Precompile additional assets
    config.assets.precompile += %w( .svg .eot .woff .ttf iframe.css )

    config.assets.version = '1.0.0'

    config.i18n.enforce_available_locales = false
    # or if one of your gem compete for pre-loading, use
    I18n.config.enforce_available_locales = false

    config.to_prepare do
      Devise::Mailer.layout "mailer"
    end

    config.generators do |generator|
      generator.test_framework :rspec
    end 
  end
end
