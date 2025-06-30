# frozen_string_literal: true

module Types
  class BaseObject < GraphQL::Schema::Object
    field_class GraphQL::Schema::Field

    include GraphQL::Types::Relay::HasNodeField
    include GraphQL::Types::Relay::HasNodesField

    connection_type_class Types::BaseConnection
    edge_type_class Types::BaseEdge
  end
end
