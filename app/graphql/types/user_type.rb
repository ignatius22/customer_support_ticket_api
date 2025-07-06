# frozen_string_literal: true

module Types
  class UserType < Types::BaseObject
    field :id, ID, null: false
    field :name, String, null: false
    field :email, String, null: false
    field :role, String, null: false
    field :file_urls, [String], null: true
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false

    def file_urls
      return [] unless object.respond_to?(:files) && object.files.attached?

      host = ENV.fetch("APP_HOST_PROD", "https://customersupportticketapi-production.up.railway.app")
      protocol = ENV.fetch("APP_PROTOCOL_PROD", "https")

      object.files.map do |file|
        Rails.application.routes.url_helpers.rails_blob_url(file, host: host, protocol: protocol)
      end
    end
  end
end
