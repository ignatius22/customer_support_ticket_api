# app/graphql/types/exported_csv_type.rb
module Types
  class ExportedCsvType < Types::BaseObject
    field :id, ID, null: false
    field :download_url, String, null: true

    def download_url
      return nil unless object.file.attached?

      Rails.application.routes.url_helpers.rails_blob_url(
        object.file,
        host: ENV.fetch("APP_HOST", "http://localhost:3000")
      )
    end
  end
end
