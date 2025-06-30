# app/jobs/daily_reminder_job.rb
class DailyReminderJob < ApplicationJob
  queue_as :default

  def perform
    User.where(role: :agent).includes(:reminder_setting, :assigned_tickets).each do |agent|
      if agent.reminder_setting&.enabled?
        open_tickets = agent.assigned_tickets.where(status: [ "open", "pending" ])

        if open_tickets.any?
          # --- CHANGE HERE: Pass agent.id and an array of open_ticket.ids ---
          DailyReminderMailer.open_tickets_reminder(agent.id, open_tickets.ids).deliver_later
          Rails.logger.info "Enqueued daily reminder email for Agent #{agent.email} with #{open_tickets.count} open tickets."
        else
          Rails.logger.info "Agent #{agent.email} has no open tickets. Skipping daily reminder (enabled)."
        end
      else
        Rails.logger.info "Daily reminders disabled or no settings for Agent #{agent.email}. Skipping email."
      end
    end
  end
end
