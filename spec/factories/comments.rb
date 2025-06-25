FactoryBot.define do
  factory :comment do
    content { "MyText" }
    ticket { nil }
    user { nil }
  end
end
