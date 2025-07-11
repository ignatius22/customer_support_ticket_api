require "sidekiq/cron/job"
require "sidekiq"
require "sidekiq-cron"

schedule_file = Rails.root.join("config/schedule.yml")

if File.exist?(schedule_file) && Sidekiq.server?
  Sidekiq::Cron::Job.load_from_hash YAML.load_file(schedule_file)
end
