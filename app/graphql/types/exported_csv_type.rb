module Types
  class ExportedCsvType < Types::BaseObject
    field :id, ID, null: false
    field :download_url, String, null: true

    def download_url
      return nil unless object.file.attached?



      def file_urls
        object.files.map { |file| file.blob.url }
      end
    end
  end
end
