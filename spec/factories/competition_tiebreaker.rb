FactoryGirl.define do
  factory :competition_tiebreaker do
    association :competition
    kind :set_wins
  end
end
