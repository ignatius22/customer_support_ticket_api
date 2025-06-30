# frozen_string_literal: true

module Types
  class TicketConnectionType < Types::BaseConnection
    edge_type_class(Types::TicketEdgeType)

    field :total_count, Integer, null: false

    def total_count
      object.items.count
    end
  end
end
