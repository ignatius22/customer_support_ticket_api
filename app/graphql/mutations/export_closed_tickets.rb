# app/graphql/mutations/export_closed_tickets.rb
require "csv"
require "stringio"

module Mutations
  class ExportClosedTickets < BaseMutation
    field :export, Types::ExportedCsvType, null: true
    field :errors, [ String ], null: false
    field :download_url, String, null: true

    def resolve
      agent = require_agent!

      tickets = Ticket.where(status: :closed)
                      .where("updated_at >= ?", 30.days.ago)

      # Using the service object here
      csv_content = TicketExporter.new(tickets).to_csv

      export = ExportedCsv.create!(user: agent)
      export.file.attach(
        io: StringIO.new(csv_content),
        filename: "closed_tickets.csv",
        content_type: "text/csv"
      )

      # Ensuring production URL options are used
      url_options = ActiveStorage::Current.url_options || {
        host: ENV.fetch("APP_HOST_PROD", "customersupportticketapi-production.up.railway.app"),
        protocol: ENV.fetch("APP_PROTOCOL_PROD", "https")
      }

      download_url = Rails.application.routes.url_helpers.rails_blob_url(
        export.file,
        host: url_options[:host],
        protocol: url_options[:protocol]
      )

      {
        export: export,
        errors: [],
        download_url: download_url
      }
    rescue => e
      {
        export: nil,
        errors: [ e.message ],
        download_url: nil
      }
    end
  end
end
