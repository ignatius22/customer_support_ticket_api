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

      BlobUrlHelper.urls_for(object.files)
    end
  end
end
