require File.expand_path('../boot', __FILE__)

# Pick the frameworks you want:
require "active_record/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
require "sprockets/railtie"
# require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(:default, Rails.env)

module Arkopter
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    config.assets.paths << Rails.root.join("vendor", "assets", "fonts")

    config.assets.precompile    += %w( *.svg *.eot *.woff *.ttf *.js *.css ) 
    config.eager_load            = true
    config.eager_load_paths     += ["#{config.root}/lib","#{config.root}/app/ninjas"] #, "#{config.root}/lib/arkopter_operations"]
    config.autoload_paths       += %W(#{config.root}/lib #{config.root}/lib/arkopter_operations) 
  end
end
