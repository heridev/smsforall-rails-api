require_relative 'boot'

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "active_storage/engine"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_mailbox/engine"
require "action_text/engine"
require "action_view/railtie"
require "action_cable/engine"
# require "sprockets/railtie"
require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module SmsparatodosApi
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.0

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    # Only loads a smaller set of middleware suitable for API only apps.
    # Middleware like session, flash, cookies can be added back manually.
    # Skip views, helpers and assets when generating a new resource.
    config.api_only = true

    # needed for the CSRF protection when using Sidekiq::Web
    config.session_store :cookie_store, key: 'smsforall_session'
    config.middleware.use ActionDispatch::Cookies
    config.middleware.use config.session_store, config.session_options

    config.i18n.default_locale = :en

    config.active_job.queue_adapter = :sidekiq

    # overrides Rails.application.credentials method
    # so this way we support multiple production servers
    # with different credentials
    def credentials
      if Rails.env.production?
        credentials_file = ENV['APP_DOMAIN'].presence || 'production'
        encrypted(
          "config/credentials_#{credentials_file}.yml.enc",
          env_key: 'RAILS_MASTER_KEY'
        )
      else
        encrypted(
          'config/credentials.yml.enc',
          # In the case you want to set the value using an env variable
          # you need to export it before running the server or rails console
          # eg:
          #   export RAILS_MASTER_KEY=bb5ffbd20b7fb60b4f05932fb2189277
          env_key: 'RAILS_MASTER_KEY',
          key_path: 'config/master.key'
        )
      end
    end
  end
end
