module Types
  class TicketConnection < Types::BaseConnection
    edge_type(Types::TicketType.edge_type)
  end
end
