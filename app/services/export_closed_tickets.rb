require "csv"

class ExportClosedTickets
  def self.call
    tickets = Ticket.where(status: :closed)
                    .where("updated_at >= ?", 30.days.ago)

    CSV.generate(headers: true) do |csv|
      csv << [ "ID", "Title", "Customer Email", "Status", "Closed At" ]

      tickets.each do |ticket|
        csv << [
          ticket.id,
          ticket.title,
          ticket.customer.email,
          ticket.status,
          ticket.updated_at.strftime("%Y-%m-%d %H:%M:%S")
        ]
      end
    end
  end
end
