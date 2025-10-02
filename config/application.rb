# frozen_string_literal: true

require_relative "boot"

require "rails/all"

Bundler.require(*Rails.groups)

module EpdiRails
  class Application < Rails::Application
    config.load_defaults 7.1

    config.time_zone = "Tokyo"
    config.active_record.default_timezone = :local

    config.autoload_paths << Rails.root.join("app", "services")
    config.autoload_paths << Rails.root.join("app", "forms")

    config.i18n.default_locale = :ja
  end
end
