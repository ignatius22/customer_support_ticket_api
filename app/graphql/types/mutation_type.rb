# app/graphql/types/mutation_type.rb
module Types
  class MutationType < Types::BaseObject
    field :export_closed_tickets, mutation: Mutations::ExportClosedTickets
    field :update_ticket_status, mutation: Mutations::UpdateTicketStatus
    field :create_ticket, mutation: Mutations::CreateTicket
    field :assign_agent_to_ticket, mutation: Mutations::AssignAgentToTicket
    field :add_comment, mutation: Mutations::AddComment
    field :add_attachment, mutation: Mutations::AddAttachment
    field :signup, mutation: Mutations::Signup
    field :login, mutation: Mutations::Login
  end
end
