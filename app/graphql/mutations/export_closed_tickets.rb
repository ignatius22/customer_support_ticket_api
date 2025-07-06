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

      csv_content = CSV.generate(headers: true) do |csv|
        csv << %w[id title customer status closed_at]
        tickets.each do |ticket|
          csv << [
            ticket.id,
            ticket.title,
            ticket.customer&.email,
            ticket.status,
            ticket.updated_at.to_date
          ]
        end
      end

      export = ExportedCsv.create!(user: agent)
      export.file.attach(
        io: StringIO.new(csv_content),
        filename: "closed_tickets.csv",
        content_type: "text/csv"
      )

      download_url = Rails.application.routes.url_helpers.rails_blob_url(export.file)


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
