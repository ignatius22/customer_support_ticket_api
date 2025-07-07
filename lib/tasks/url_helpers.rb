module UrlHelpers
  def file_url_for(attachment)
    return nil unless attachment.attached?

    Rails.application.routes.url_helpers.rails_blob_url(
      attachment,
      host: ActiveStorage::Current.url_options[:host],
      protocol: ActiveStorage::Current.url_options[:protocol]
    )
  end
end
