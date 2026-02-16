# Generate a secret key for development/test environments
# In production, use proper Rails credentials or environment variables
unless Rails.env.production?
  Rails.application.config.secret_key_base = ENV.fetch("SECRET_KEY_BASE") do
    require "securerandom"
    SecureRandom.hex(64)
  end
end
