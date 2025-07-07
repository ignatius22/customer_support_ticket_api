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
      return [] unless object.respond_to?(:files) && object.files.attached?

      BlobUrlHelper.urls_for(object.files)
    end
  end
end
