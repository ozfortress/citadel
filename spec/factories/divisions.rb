FactoryGirl.define do
  factory :division do
    sequence(:name) { |n| "Div #{n}" }
    description "We're not good yet"
    competition
  end
end
