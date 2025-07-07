class DailyReminderJob < ApplicationJob
  queue_as :default

  def perform
    Cronitor.ping("daily-reminder-job-start")
  
    tickets_by_agent = Ticket.where(status: :open).where.not(agent_id: nil).limit(1000).group_by(&:agent_id)
  
    agents = User.where(id: tickets_by_agent.keys, role: :agent)
  
    agents.find_each do |agent|
      ticket_ids = tickets_by_agent[agent.id]&.map(&:id) || []
      next if ticket_ids.empty?
  
      AgentMailer.daily_reminder(agent.id, ticket_ids).deliver_later
    end
  
    Cronitor.ping("daily-reminder-job-complete")
  rescue => e
    Cronitor.ping("daily-reminder-job-failed")
    raise e
  end
  
end
