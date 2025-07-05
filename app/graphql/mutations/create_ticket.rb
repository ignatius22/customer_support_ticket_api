module Mutations
  class CreateTicket < BaseMutation
    argument :title, String, required: true
    argument :description, String, required: true

    field :ticket, Types::TicketType, null: true
    field :errors, [ String ], null: false

    def resolve(title:, description:)
      user = require_customer!

      ticket = Ticket.new(
        title: title,
        description: description,
        customer: user
      )

      if ticket.save
        { ticket: ticket, errors: [] }
      else
        { ticket: nil, errors: ticket.errors.full_messages }
      end
    end
  end
end
