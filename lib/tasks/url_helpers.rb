module UrlHelpers
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
