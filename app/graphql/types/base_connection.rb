# frozen_string_literal: true

module Types
  class BaseConnection < GraphQL::Types::Relay::BaseConnection
    edge_type_class Types::BaseEdge
    field_class GraphQL::Schema::Field

    field :total_count, Integer, null: false
    field :total_pages, Integer, null: false

    def total_count
      object.items.count
    end

    def total_pages
      (total_count.to_f / first).ceil
    end
  end
end
