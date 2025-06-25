FactoryBot.define do
  factory :user do
    sequence(:name) { |n| "Test User #{n}" }
    sequence(:email) { |n| "user#{n}@example.com" }
    password { "password123" }
    role { :customer }

    trait :agent do
      role { :agent }
    end
  end
end
