class TicketMailer < ApplicationMailer
  default from: "no-reply@supportapp.com"

  def closed_tickets_csv(agent, csv_data)
    attachments["closed_tickets.csv"] = {
      mime_type: "text/csv",
      content: csv_data
    }

    mail(
      to: agent.email,
      subject: "Exported Closed Tickets Report"
    )
  end
end
