# app/graphql/mutations/assign_agent_to_ticket.rb
module Mutations
  class AssignAgentToTicket < BaseMutation
    argument :ticket_id, ID, required: true
    argument :agent_id, ID, required: false

    field :ticket, Types::TicketType, null: true
    field :errors, [ String ], null: false

    def resolve(ticket_id:, agent_id: nil)
      user = context[:current_user]
      return { ticket: nil, errors: [ "Unauthorized" ] } unless user&.role == "agent"

      ticket = Ticket.find_by(id: ticket_id)
      return { ticket: nil, errors: [ "Ticket not found" ] } unless ticket

      agent = agent_id.present? ? User.find_by(id: agent_id, role: "agent") : user
      return { ticket: nil, errors: [ "Agent not found" ] } unless agent

      ticket.agent = agent

      if ticket.save
        { ticket: ticket, errors: [] }
      else
        { ticket: nil, errors: ticket.errors.full_messages }
      end
    end
  end
end
