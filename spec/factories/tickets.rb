FactoryBot.define do
  factory :ticket do
    title { "Issue with login" }
    description { "User cannot login to the dashboard." }
    status { :open }
    association :customer, factory: :user

    trait :with_agent do
      association :agent, factory: [ :user, :agent ]
    end

    trait :in_progress do
      status { :in_progress }
    end

    trait :closed do
      status { :closed }
    end
  end
end
