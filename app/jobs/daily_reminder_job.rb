class DailyReminderJob < ApplicationJob
  include Sidekiq::Job 

  def perform
    Cronitor.wrap('MONITOR_KEY') do
      agent_ids = Ticket.where(status: :open).pluck(:agent_id).uniq.compact
      agents = User.where(id: agent_ids, role: :agent)

      agents.find_each do |agent|
        tickets = Ticket.where(agent_id: agent.id, status: :open).limit(10)
        # Use deliver_later for async mail delivery in a background job
        AgentMailer.daily_reminder(agent.id, tickets.map(&:id)).deliver_later if tickets.any?
      end
    end
  end
end