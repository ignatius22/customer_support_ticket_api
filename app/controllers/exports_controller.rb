class ExportsController < ApplicationController
  def show
    export = ExportedCsv.find(params[:id])

    send_data export.csv_data,
              filename: "tickets_export_#{export.created_at.to_date}.csv",
              type: 'text/csv'
  end
end
