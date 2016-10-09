FactoryGirl.define do
  factory :team_player, class: 'Team::Player' do
    user
    team
  end
end
