# frozen_string_literal: true

module Types
  class UserType < Types::BaseObject
    field :id, ID, null: false
    field :name, String, null: false
    field :email, String, null: false
    field :password_digest, String, null: false
    field :role, String, null: false
    field :file_urls, [ String ], null: true
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false


    def file_urls
      object.files.map { |file| file.blob.url }
    end
  end
end
