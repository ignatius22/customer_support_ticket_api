module Mutations
  class UpdateTicketStatus < BaseMutation
    argument :ticket_id, ID, required: true
    argument :status, String, required: true

    field :ticket, Types::TicketType, null: true
    field :errors, [ String ], null: false

    def resolve(ticket_id:, status:)
      user = require_agent!

      ticket = Ticket.find_by(id: ticket_id)
      return { ticket: nil, errors: [ "Ticket not found" ] } unless ticket

      unless Ticket.statuses.key?(status)
        return { ticket: nil, errors: [ "Invalid status: #{status}" ] }
      end

      ticket.status = status
      ticket.agent ||= user

      if ticket.save
        { ticket: ticket, errors: [] }
      else
        { ticket: nil, errors: ticket.errors.full_messages }
      end
    end
  end
end
