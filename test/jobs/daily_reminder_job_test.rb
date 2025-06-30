require "test_helper"

class DailyReminderJobTest < ActiveJob::TestCase
  def setup
    @agent = users(:agent)
    @settings = reminder_settings(:agent_settings)
    @open_tickets = [ tickets(:one), tickets(:two) ]
  end

  test "should send daily reminder to agents with open tickets" do
    assert_enqueued_emails 1 do
      DailyReminderJob.perform_now
    end

    email = ActionMailer::Base.deliveries.last
    assert_equal [ @agent.email ], email.to
    assert_match "You have 2 open tickets", email.body.to_s
  end

  test "should not send daily reminder to agents with disabled reminders" do
    @settings.update!(enabled: false)

    assert_no_enqueued_emails do
      DailyReminderJob.perform_now
    end
  end
end
