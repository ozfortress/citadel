FactoryGirl.define do
  factory :competition_transfer do
    association :roster, factory: :competition_roster
    user
    is_joining true
    approved false
  end
end
