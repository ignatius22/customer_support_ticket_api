class AgentMailerPreview < ActionMailer::Preview
  def daily_reminder
    agent = User.where(role: :agent).first
    tickets = Ticket.where(agent: agent, status: :open)

    AgentMailer.daily_reminder(agent, tickets)
  end
end
