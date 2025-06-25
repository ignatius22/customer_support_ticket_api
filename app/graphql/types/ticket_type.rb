# app/graphql/types/ticket_type.rb
module Types
  class TicketType < Types::BaseObject
    field :id, ID, null: false
    field :title, String, null: false
    field :description, String, null: false
    field :status, String, null: false
    field :customer, Types::UserType, null: false
    field :agent, Types::UserType, null: true
  end
end
