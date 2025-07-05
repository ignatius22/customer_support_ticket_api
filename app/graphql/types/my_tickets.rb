# app/graphql/resolvers/my_tickets.rb
module Resolvers
  class MyTickets < GraphQL::Schema::Resolver
    type Types::TicketType.connection_type, null: false
    description "Returns tickets for the current customer"

    argument :status, String, required: false

    def resolve(status: nil)
      user = context[:current_user]
      raise GraphQL::ExecutionError, "Unauthorized" unless user&.customer?

      tickets = Ticket.where(customer_id: user.id)
      tickets = tickets.where(status: status) if status.present?
      tickets.order(created_at: :desc)
    end
  end
end
