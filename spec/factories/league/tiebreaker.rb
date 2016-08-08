FactoryGirl.define do
  factory :league_tiebreaker, class: League::Tiebreaker do
    association :league
    kind :set_wins
  end
end
