FactoryGirl.define do
  factory :league_match_round, class: League::Match::Round do
    association :match, factory: :league_match
    map
    home_team_score 3
    away_team_score 3
  end
end
