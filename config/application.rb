require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile
Bundler.require(*Rails.groups)

module FullstackTakeHome
  class Application < Rails::Application
    config.load_defaults 8.0

    # Use RSpec for testing
    config.generators do |g|
      g.test_framework :rspec
    end

    # Autoload lib directory
    config.autoload_lib(ignore: %w[assets tasks])

    # Don't autoload graphql - we'll require it once to avoid reload issues
    config.autoload_paths -= [Rails.root.join("app/graphql").to_s]
    config.eager_load_paths -= [Rails.root.join("app/graphql").to_s]
  end
end
