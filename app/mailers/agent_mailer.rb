class AgentMailer < ApplicationMailer
  default from: "support@example.com"

  def daily_reminder(agent_id, ticket_ids)
    @agent = User.find(agent_id)
    @tickets = Ticket.where(id: ticket_ids)

    mail(to: @agent.email, subject: "You have #{@tickets.count} open tickets")
  end
end
