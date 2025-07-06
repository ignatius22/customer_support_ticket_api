module Types
  class ExportedCsvType < Types::BaseObject
    field :id, ID, null: false
    field :download_url, String, null: true

    def download_url
      return nil unless object.file.attached?

      host = ENV.fetch("APP_HOST_PROD") { raise "APP_HOST_PROD not set" }
      protocol = ENV.fetch("APP_PROTOCOL_PROD", "https")

      Rails.application.routes.url_helpers.rails_blob_url(
        object.file,
        host: host,
        protocol: protocol
      )
    end
  end
end
