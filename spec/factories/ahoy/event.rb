FactoryGirl.define do
  factory :ahoy_event, class: Ahoy::Event do
    user
    visit
  end
end
