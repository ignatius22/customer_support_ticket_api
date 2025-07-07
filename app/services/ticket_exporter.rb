require "csv"


class TicketExporter
  def initialize(tickets)
    @tickets = tickets
  end

  def to_csv
    CSV.generate(headers: true) do |csv|
      csv << %w[id title customer status closed_at]
      @tickets.each do |ticket|
        csv << [
          ticket.id,
          ticket.title,
          ticket.customer&.email,
          ticket.status,
          ticket.updated_at.to_date
        ]
      end
    end
  end
end
