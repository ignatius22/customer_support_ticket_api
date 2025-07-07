module Types
  class ExportedCsvType < Types::BaseObject
    field :id, ID, null: false
    field :download_url, String, null: true

    def download_url
      return nil unless object.file.attached?

      Rails.application.routes.url_helpers.rails_blob_url(
        object.file,
        host: ActiveStorage::Current.url_options[:host],
        protocol: ActiveStorage::Current.url_options[:protocol]
      )
    end
  end
end
