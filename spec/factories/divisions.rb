FactoryGirl.define do
  factory :division do
    sequence(:name) { |n| "Div #{n}" }
    competition
  end
end
