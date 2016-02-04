FactoryGirl.define do
  factory :competition_transfer do
    association :roster, factory: :competition_roster
    user
  end
end
