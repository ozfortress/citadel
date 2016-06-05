FactoryGirl.define do
  factory :competition_set do
    association :match, factory: :competition_match
    map
    home_team_score 3
    away_team_score 3
  end
end
