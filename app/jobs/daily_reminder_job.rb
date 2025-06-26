class DailyReminderJob < ApplicationJob
  queue_as :default

  def perform
    # Force query execution so we pass an array
    agents = User.where(role: :agent)
                 .joins(:tickets)
                 .where(tickets: { status: :open })
                 .distinct

    agents.find_each do |agent|
      AgentMailer.daily_reminder(agent).deliver_later
    end
  end
end
