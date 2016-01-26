FactoryGirl.define do
  factory :format do
    name '6s'
    description '6 players vs 6 other players'
    player_count 6
    game { create(:game) }
  end
end
