# app/graphql/types/query_type.rb
module Types
  class QueryType < Types::BaseObject
    # 🧠 Relay-style node fetchers (keep if using global IDs)
    field :node, Types::NodeType, null: true do
      argument :id, ID, required: true
    end

    def node(id:)
      context.schema.object_from_id(id, context)
    end

    field :nodes, [ Types::NodeType, null: true ], null: true do
      argument :ids, [ ID ], required: true
    end

    def nodes(ids:)
      ids.map { |id| context.schema.object_from_id(id, context) }
    end

    # 🔍 Generic tickets query (optional filters)
    field :tickets, [ Types::TicketType ], null: false do
      argument :status, String, required: false
      argument :customer_id, ID, required: false
    end

    def tickets(status: nil, customer_id: nil)
      scope = Ticket.all
      scope = scope.where(status: status) if status.present?
      scope = scope.where(customer_id: customer_id) if customer_id.present?
      scope
    end

    field :my_tickets, [ Types::TicketType ], null: false,
      description: "Tickets belonging to the currently authenticated customer"

    def my_tickets
      user = context[:current_user]
      raise GraphQL::ExecutionError, "Unauthorized" unless user&.role == "customer"

      Ticket.where(customer_id: user.id)
    end

    # 🧑‍💼 All Tickets (agent only)
    field :all_tickets, [ Types::TicketType ], null: false,
      description: "All tickets — agent-only access"

    def all_tickets
      user = context[:current_user]
      raise GraphQL::ExecutionError, "Unauthorized" unless user&.role == "agent"

      Ticket.all
    end

    # 🔍 Get one ticket by ID
    field :ticket, Types::TicketType, null: true do
      argument :id, ID, required: true
    end

    def ticket(id:)
      user = context[:current_user]
      ticket = Ticket.find_by(id: id)
      return nil unless ticket

      if user&.role == "agent" || ticket.customer_id == user&.id
        ticket
      else
        raise GraphQL::ExecutionError, "Unauthorized"
      end
    end

    field :comments, [ Types::CommentType ], null: false do
      argument :ticket_id, ID, required: true
    end

    def comments(ticket_id:)
      ticket = Ticket.find_by(id: ticket_id)
      raise GraphQL::ExecutionError, "Ticket not found" unless ticket

      user = context[:current_user]

      # Only allow if current_user owns the ticket or is agent
      if user&.role == "agent" || user&.id == ticket.customer_id
        ticket.comments.order(:created_at)
      else
        raise GraphQL::ExecutionError, "Unauthorized"
      end
    end
  end
end
