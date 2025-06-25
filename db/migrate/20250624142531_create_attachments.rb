class CreateAttachments < ActiveRecord::Migration[8.0]
  def change
    create_table :attachments do |t|
      t.string :file
      t.references :ticket, null: false, foreign_key: true

      t.timestamps
    end
  end
end
