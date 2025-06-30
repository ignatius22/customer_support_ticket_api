# app/models/reminder_setting.rb
class ReminderSetting < ApplicationRecord
  belongs_to :user
end
