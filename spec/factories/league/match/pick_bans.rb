FactoryGirl.define do
  factory :league_match_pick_ban, class: 'League::Match::PickBan' do
    match
    picked_by nil
    kind :pick
    team :home_team
  end
end
