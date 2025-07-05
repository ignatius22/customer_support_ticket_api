require "sidekiq"
require "sidekiq-scheduler"
require "sidekiq-scheduler/web" # Enables Recurring Jobs tab
require "cronitor"

Sidekiq.configure_server do |config|
  config.redis = { url: ENV.fetch("REDIS_URL", "redis://localhost:6379/0") }

  config.on(:startup) do
    schedule_file = Rails.root.join("config/sidekiq_scheduler.yml")

    if File.exist?(schedule_file)
      Sidekiq::Scheduler.dynamic = true
      Sidekiq.schedule = YAML.load_file(schedule_file)
      Sidekiq::Scheduler.reload_schedule!
      Rails.logger.info "✅ Sidekiq schedule loaded from #{schedule_file}"
    else
      Rails.logger.warn "⚠️ No Sidekiq schedule file found at #{schedule_file}"
    end
  end

  config.server_middleware do |chain|
    chain.add Sidekiq::Cronitor::ServerMiddleware
  end
end

Sidekiq.configure_client do |config|
  config.redis = { url: ENV.fetch("REDIS_URL", "redis://localhost:6379/0") }
end
