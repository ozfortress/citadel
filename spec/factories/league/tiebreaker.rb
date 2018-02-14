FactoryBot.define do
  factory :league_tiebreaker, class: League::Tiebreaker do
    association :league
    kind :round_wins
  end
end
