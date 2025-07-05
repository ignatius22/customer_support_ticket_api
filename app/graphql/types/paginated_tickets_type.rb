# app/graphql/types/paginated_tickets_type.rb
module Types
  class PaginatedTicketsType < Types::BaseObject
    field :tickets, [ Types::TicketType ], null: false
    field :current_page, Integer, null: false
    field :total_pages, Integer, null: false
    field :total_count, Integer, null: false
  end
end
