require_relative 'boot'

require 'rails/all'

# Required for some fucking reason
require 'uri'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Ozfortress
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.0

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    # Make view helpers, view specific
    config.action_controller.include_all_helpers = false

    # Use dynamic error pages
    config.exceptions_app = self.routes

    # News config file
    config.news = config_for(:news)
  end
end
