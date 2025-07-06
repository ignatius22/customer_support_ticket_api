# config/environments/production.rb
require "active_support/core_ext/integer/time"

Rails.application.configure do
  # Code is not reloaded between requests.
  config.enable_reloading = false

  # Eager load code on boot for performance.
  config.eager_load = true

  # Disable full error reports.
  config.consider_all_requests_local = false

  # Cache public assets (fingerprinted).
  config.public_file_server.headers = {
    "Cache-Control" => "public, max-age=#{1.year.to_i}"
  }

  # Use Cloudinary for file storage.
  config.active_storage.service = :cloudinary

  # Enforce SSL.
  config.assume_ssl = true
  config.force_ssl = true

  # Get the host from an environment variable for production URLs
  # Make sure to set this environment variable in your production environment (e.g., Heroku, server config)
  # Example: APP_HOST=your-production-domain.com
  production_host = ENV.fetch("APP_HOST_PROD") {
    raise "APP_HOST_PROD environment variable is not set for production!"
  }
  production_protocol = ENV.fetch("APP_PROTOCOL", "https") # Default to https

  # Logging
  config.log_tags  = [ :request_id ]
  config.logger    = ActiveSupport::TaggedLogging.logger(STDOUT)
  config.log_level = ENV.fetch("RAILS_LOG_LEVEL", "info")
  config.silence_healthcheck_path = "/up"
  config.active_support.report_deprecations = false

  # Caching
  # config.cache_store = :solid_cache_store

  # Background Jobs — now using Sidekiq
  config.active_job.queue_adapter = :sidekiq

  # Email delivery setup
  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.default_url_options = { host: production_host, protocol: production_protocol }

  # IMPORTANT: Set default URL options for Rails routes to ensure Active Storage
  # can generate full URLs, especially when using a service like Cloudinary.
  config.action_controller.default_url_options = { host: production_host, protocol: production_protocol }
  Rails.application.routes.default_url_options = { host: production_host, protocol: production_protocol }


  config.action_mailer.smtp_settings = {
    user_name: Rails.application.credentials.dig(:smtp, :user_name),
    password:  Rails.application.credentials.dig(:smtp, :password),
    address:   "smtp.sendgrid.net", # or smtp.mailgun.org etc.
    port:      587,
    authentication: :plain,
    enable_starttls_auto: true
  }

  # I18n fallbacks
  config.i18n.fallbacks = true

  # Schema dump
  config.active_record.dump_schema_after_migration = false
  config.active_record.attributes_for_inspect = [ :id ]
end
