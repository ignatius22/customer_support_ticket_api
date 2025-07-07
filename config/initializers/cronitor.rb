if Rails.env.production?
  Cronitor.api_key = ENV.fetch("CRONITOR_API_KEY") do
    Rails.logger.warn "CRONITOR_API_KEY environment variable not set for production. Cronitor monitoring will not work."
    nil # Or raise an error if you want to enforce it strictly
  end
end
