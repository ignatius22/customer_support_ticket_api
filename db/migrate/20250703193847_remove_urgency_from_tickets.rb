class RemoveUrgencyFromTickets < ActiveRecord::Migration[8.0]
  def change
    remove_column :tickets, :urgency, :integer
  end
end
