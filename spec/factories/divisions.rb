FactoryGirl.define do
  factory :division do
    sequence(:name) { |n| "Div #{n}" }
    competition
    min_teams 4
    max_teams 16
    min_players 5
    max_players 12
  end
end
