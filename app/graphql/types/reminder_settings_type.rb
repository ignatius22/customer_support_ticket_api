# frozen_string_literal: true

module Types
  class ReminderSettingsType < Types::BaseObject
    field :id, ID, null: false
    field :user_id, ID, null: false
    field :enabled, Boolean, null: false
    field :preferred_time, String, null: false
    field :include_urgent, Boolean, null: false
    field :include_stale, Boolean, null: false
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false
  end
end
