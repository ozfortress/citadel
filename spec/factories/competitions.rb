FactoryGirl.define do
  factory :competition do
    sequence(:name) { |n| "OWL #{n}" }
    description "The owl that won't happen"
    format
  end
end
