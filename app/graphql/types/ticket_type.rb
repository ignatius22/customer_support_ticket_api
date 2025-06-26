# app/graphql/types/ticket_type.rb
module Types
  class TicketType < Types::BaseObject
    field :id, ID, null: false
    field :title, String, null: false
    field :description, String, null: false
    field :status, String, null: false
    field :customer, Types::UserType, null: false
    field :agent, Types::UserType, null: true

    # Add this field to expose attachment URLs
    field :file_urls, [String], null: true

    def file_urls
      object.files.map do |file|
        Rails.application.routes.url_helpers.rails_blob_url(file, only_path: true)
      end
    end
  end
end
