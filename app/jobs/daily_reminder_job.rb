class DailyReminderJob < ApplicationJob
  queue_as :default

  # Add Cronitor hook (must match monitor slug in Cronitor dashboard)
  Cronitor.job "daily-reminder-check"

  def perform
    agent_ids = Ticket.where(status: :open).pluck(:agent_id).uniq.compact
    agents = User.where(id: agent_ids, role: :agent)

    agents.find_each do |agent|
      tickets = Ticket.where(agent_id: agent.id, status: :open).limit(10)
      if tickets.any?
        AgentMailer.daily_reminder(agent.id, tickets.map(&:id)).deliver_later
      end
    end
  end
end
