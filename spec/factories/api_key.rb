FactoryBot.define do
  factory :api_key do
    sequence(:name) { |n| "key-#{n}" }
    user nil
  end
end
