module Types
  class TicketType < Types::BaseObject
    field :id, ID, null: false
    field :title, String, null: false
    field :description, String, null: false
    field :status, Types::TicketStatusEnum, null: false

    field :customer, Types::UserType, null: false
    field :agent, Types::UserType, null: true
    field :comments, [Types::CommentType], null: false
    field :file_urls, [String], null: false

    def file_urls
      return [] unless object.files.attached?

      object.files.map do |file|
        Rails.application.routes.url_helpers.rails_blob_url(
          file,
          host: ENV.fetch("APP_HOST_PROD", "https://customersupportticketapi-production.up.railway.app"),
          protocol: "https"
        )
      end
    end
  end
end

