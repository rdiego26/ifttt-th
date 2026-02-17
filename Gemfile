source "https://rubygems.org"

ruby "4.0.1"

# Rails 8
gem "rails", "~> 8.1.2"

# Database
gem "pg", "~> 1.5"

# Web server
gem "puma", ">= 5.0"

# Assets
gem "sprockets-rails"
gem "vite_rails"

# GraphQL
gem "graphql", "~> 2.2"

# Performance
gem "bootsnap", require: false

# Reduces boot times through caching
gem "tzinfo-data", platforms: %i[windows jruby]

group :development, :test do
  gem "debug", platforms: %i[mri windows], require: "debug/prelude"
  gem "rspec-rails", "~> 6.1"
  gem "factory_bot_rails"
  gem "faker"
  gem "standard", require: false
end

group :development do
  gem "web-console"
  gem "graphiql-rails"
end

group :test do
  gem "capybara"
  gem "selenium-webdriver"
end
