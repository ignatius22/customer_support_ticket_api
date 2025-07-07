class BlobUrlHelper
  def self.urls_for(attachments)
    return [] unless attachments.respond_to?(:each)

    url_options = ActiveStorage::Current.url_options || {
      host: ENV.fetch("APP_HOST_PROD", "https://customersupportticketapi-production.up.railway.app"),
      protocol: ENV.fetch("APP_PROTOCOL_PROD", "https")
    }

    attachments.map do |file|
      Rails.application.routes.url_helpers.rails_blob_url(file, url_options)
    end
  end
end
