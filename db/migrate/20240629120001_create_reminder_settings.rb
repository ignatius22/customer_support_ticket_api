class CreateReminderSettings < ActiveRecord::Migration[7.0]
  def change
    create_table :reminder_settings do |t|
      t.references :user, null: false, foreign_key: true
      t.boolean :enabled, default: true, null: false
      t.string :preferred_time, default: "09:00", null: false
      t.boolean :include_urgent, default: true, null: false
      t.boolean :include_stale, default: true, null: false

      t.timestamps
    end

    add_index :reminder_settings, [ :user_id, :enabled ]
  end
end
