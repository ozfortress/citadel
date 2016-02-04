FactoryGirl.define do
  factory :competition do |c|
    sequence(:name) { |n| "OWL #{n}" }
    description "The owl that won't happen"
    format
    c.private true
    signuppable false
    roster_locked false
  end
end
