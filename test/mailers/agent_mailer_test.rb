require "test_helper"

class AgentMailerTest < ActionMailer::TestCase
  def setup
    @agent = users(:agent)
    @settings = reminder_settings(:agent_settings)
    @open_tickets = [ tickets(:one), tickets(:two) ]
    @urgent_tickets = [ tickets(:urgent) ]
    @stale_tickets = [ tickets(:stale) ]
  end

  test "daily_reminder with all ticket types" do
    email = AgentMailer.daily_reminder(@agent, {
      open: @open_tickets,
      urgent: @urgent_tickets,
      stale: @stale_tickets
    })

    assert_emails 1 do
      email.deliver_now
    end

    assert_equal [ "support@example.com" ], email.from
    assert_equal [ @agent.email ], email.to
    assert_equal "Daily Reminder: 2 open tickets", email.subject

    assert_match "You have 2 open tickets", email.body.to_s
    assert_match "1 urgent ticket", email.body.to_s
    assert_match "1 stale ticket", email.body.to_s
  end

  test "daily_reminder without urgent and stale tickets" do
    @settings.update!(include_urgent: false, include_stale: false)

    email = AgentMailer.daily_reminder(@agent, {
      open: @open_tickets,
      urgent: @urgent_tickets,
      stale: @stale_tickets
    })

    assert_emails 1 do
      email.deliver_now
    end

    assert_match "You have 2 open tickets", email.body.to_s
    assert_no_match "urgent ticket", email.body.to_s
    assert_no_match "stale ticket", email.body.to_s
  end
end
