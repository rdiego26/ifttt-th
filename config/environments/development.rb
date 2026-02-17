require "active_support/core_ext/integer/time"

Rails.application.configure do
  config.enable_reloading = true
  config.eager_load = false
  config.consider_all_requests_local = true
  config.server_timing = true

  if Rails.root.join("tmp/caching-dev.txt").exist?
    config.action_controller.perform_caching = true
    config.action_controller.enable_fragment_cache_logging = true
    config.cache_store = :memory_store
    config.public_file_server.headers = {"Cache-Control" => "public, max-age=#{1.days.to_i}"}
  else
    config.action_controller.perform_caching = false
    config.cache_store = :null_store
  end

  config.active_storage.service = :local if defined?(ActiveStorage)
  config.action_mailer.raise_delivery_errors = false if defined?(ActionMailer)
  config.action_mailer.perform_caching = false if defined?(ActionMailer)
  config.active_support.deprecation = :log
  config.active_support.disallowed_deprecation = :raise
  config.active_support.disallowed_deprecation_warnings = []
  config.active_record.migration_error = :page_load
  config.active_record.verbose_query_logs = true
  config.action_view.annotate_rendered_view_with_filenames = true
  config.action_controller.raise_on_missing_callback_actions = true

  config.web_console.allowed_ips = %w[172.66.0.0/12 192.168.0.0/12 127.0.0.1]
end
