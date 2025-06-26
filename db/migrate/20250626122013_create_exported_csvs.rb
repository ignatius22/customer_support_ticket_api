class CreateExportedCsvs < ActiveRecord::Migration[8.0]
  def change
    create_table :exported_csvs do |t|
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
