FactoryGirl.define do
  factory :competition_comm do
    user
    association :match, factory: :competition_match
    sequence(:content) { |n| "Can we play at #{n}:00" }
  end
end
