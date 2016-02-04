FactoryGirl.define do
  factory :format do
    sequence(:name) { |n| "#{n}s" }
    description '6 players vs 6 other players'
    player_count 6
    game
  end
end
