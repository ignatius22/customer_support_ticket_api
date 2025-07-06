module Types
  class QueryType < Types::BaseObject
    #  Authenticated user
    field :me, Types::UserType, null: true

    def me
      context[:current_user]
    end


    field :my_tickets, Types::PaginatedTicketsType, null: false do
      argument :page, Integer, required: false, default_value: 1
      argument :per_page, Integer, required: false, default_value: 10
    end

    def my_tickets(page:, per_page:)
      user = context[:current_user]
      raise GraphQL::ExecutionError, "Unauthorized" unless user&.customer?

      tickets = user.tickets.order(created_at: :desc).page(page).per(per_page)

      {
        tickets: tickets,
        current_page: tickets.current_page,
        total_pages: tickets.total_pages,
        total_count: tickets.total_count
      }
    end


    field :all_tickets, Types::PaginatedTicketsType, null: false do
      argument :page, Integer, required: false, default_value: 1
      argument :per_page, Integer, required: false, default_value: 10
      argument :status, Types::TicketStatusEnum, required: false
    end




    def all_tickets(page:, per_page:, status: nil)
      user = context[:current_user]
      raise GraphQL::ExecutionError, "Unauthorized" unless user&.agent?

      scope = Ticket.order(created_at: :desc)

      # ↓ Normalize GraphQL enum (e.g. "OPEN") to model enum (e.g. "open")
      scope = scope.where(status: status.downcase) if status.present?

      tickets = scope.page(page).per(per_page)

      {
        tickets: tickets,
        current_page: tickets.current_page,
        total_pages: tickets.total_pages,
        total_count: tickets.total_count
      }
    end

    # Fetch single ticket (restricted)
    field :ticket, Types::TicketType, null: true do
      argument :id, ID, required: true
    end

    def ticket(id:)
      user = context[:current_user]
      raise GraphQL::ExecutionError, "Unauthorized" unless user

      ticket = Ticket.find_by(id: id)
      return nil unless ticket

      if user.agent? || ticket.customer_id == user.id
        ticket
      else
        raise GraphQL::ExecutionError, "Access denied"
      end
    end

    field :comments, [ Types::CommentType ], null: false do
      argument :ticket_id, ID, required: true
    end


    def comments(ticket_id:)
      user = context[:current_user]
      raise GraphQL::ExecutionError, "Unauthorized" unless user

      ticket = Ticket.find_by(id: ticket_id)
      raise GraphQL::ExecutionError, "Ticket not found" unless ticket

      # Optional: only allow customer/agent associated with ticket
      if user.agent? || ticket.customer_id == user.id
        ticket.comments.includes(:user)
      else
        raise GraphQL::ExecutionError, "Access denied"
      end
    end
  end
end
