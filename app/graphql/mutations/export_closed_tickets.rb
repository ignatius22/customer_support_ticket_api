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

      csv_content = TicketExporter.new(tickets).to_csv

      export = ExportedCsv.create!(user: agent)
      export.file.attach(
        io: StringIO.new(csv_content),
        filename: "closed_tickets.csv",
        content_type: "text/csv"
      )

      download_url = Rails.application.routes.url_helpers.rails_blob_url(
        export.file,
        host: ENV.fetch("APP_HOST", "http://localhost:3000")
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
