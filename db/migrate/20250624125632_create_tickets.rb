class CreateTickets < ActiveRecord::Migration[8.0]
  create_table :tickets do |t|
    t.string :title, null: false
    t.text :description, null: false
    t.integer :status, default: 0, null: false  # enum: open, in_progress, closed

    # Foreign keys
    t.references :customer, null: false, foreign_key: { to_table: :users }
    t.references :agent, foreign_key: { to_table: :users }, null: true

    t.timestamps
  end
end
