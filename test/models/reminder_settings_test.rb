require "test_helper"

class ReminderSettingsTest < ActiveSupport::TestCase
  def setup
    @user = users(:agent)
    @settings = reminder_settings(:agent_settings)
  end

  test "should be valid with default values" do
    settings = ReminderSettings.new(user: @user)
    assert settings.valid?
    assert_equal "09:00", settings.preferred_time
    assert settings.enabled?
    assert settings.include_urgent?
    assert settings.include_stale?
  end

  test "should belong to a user" do
    settings = ReminderSettings.new
    assert_not settings.valid?
    assert_includes settings.errors[:user], "must exist"
  end

  test "should validate preferred_time format" do
    @settings.preferred_time = "not a time"
    assert_not @settings.valid?
    assert_includes @settings.errors[:preferred_time], "must be in HH:MM format"

    @settings.preferred_time = "25:00"
    assert_not @settings.valid?
    assert_includes @settings.errors[:preferred_time], "must be a valid time"

    @settings.preferred_time = "09:60"
    assert_not @settings.valid?
    assert_includes @settings.errors[:preferred_time], "must be a valid time"

    @settings.preferred_time = "09:00"
    assert @settings.valid?
  end

  test "should create default settings for new agent" do
    user = User.create!(
      email: "new_agent@example.com",
      password: "password123",
      password_confirmation: "password123",
      role: "agent"
    )

    assert user.reminder_settings.present?
    assert_equal "09:00", user.reminder_settings.preferred_time
    assert user.reminder_settings.enabled?
  end

  test "should not create settings for customer" do
    user = User.create!(
      email: "customer@example.com",
      password: "password123",
      password_confirmation: "password123",
      role: "customer"
    )

    assert_nil user.reminder_settings
  end
end
