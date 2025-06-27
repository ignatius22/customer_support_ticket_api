class AgentMailer < ApplicationMailer
  default from: "support@example.com" # update as needed

  def daily_reminder(agent, tickets)
    @agent = agent
    @tickets = tickets

    mail(
      to: @agent.email,
      subject: "Daily Reminder: You have #{@tickets.size} open ticket(s)"
    )
  end
end
