# frozen_string_literal: true

module Types
  class TicketEdgeType < Types::BaseEdge
    node_type(Types::TicketType)
  end
end
