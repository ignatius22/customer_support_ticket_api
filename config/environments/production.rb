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

  # --- START: ENVIRONMENT VARIABLE CONFIGURATION FOR HOST & PROTOCOL ---
  # These variables MUST be set in your Railway project's service environment variables.
  # Example for APP_HOST_PROD: your-app-name.up.railway.app OR api.yourdomain.com
  # Example for APP_PROTOCOL_PROD: https
  production_host = ENV.fetch("APP_HOST_PROD") do
    raise "APP_HOST_PROD environment variable is not set for production! Please configure it on Railway."
  end
  production_protocol = ENV.fetch("APP_PROTOCOL_PROD", "https") # Defaults to https if not explicitly set

  # --- END: ENVIRONMENT VARIABLE CONFIGURATION ---

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

  config.action_mailer.smtp_settings = {
    user_name: Rails.application.credentials.dig(:smtp, :user_name),
    password:  Rails.application.credentials.dig(:smtp, :password),
    address:   "smtp.sendgrid.net", # or smtp.mailgun.org etc.
    port:      587,
    authentication: :plain,
    enable_starttls_auto: true
  }

  # --- START: CRITICAL URL OPTIONS FOR ACTIVE STORAGE AND ROUTES ---
  # These lines are absolutely ESSENTIAL for Active Storage to generate
  # correct, full URLs for your attachments (e.g., in TicketType#file_urls).
  # They provide the necessary host and protocol context to the Rails URL helpers.
  config.action_controller.default_url_options = { host: production_host, protocol: production_protocol }
  Rails.application.routes.default_url_options = { host: production_host, protocol: production_protocol }
  # --- END: CRITICAL URL OPTIONS ---

  # I18n fallbacks
  config.i18n.fallbacks = true

  # Schema dump
  config.active_record.dump_schema_after_migration = false
  config.active_record.attributes_for_inspect = [ :id ]
end