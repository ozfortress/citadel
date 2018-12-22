FactoryBot.define do
  factory :league_match_pick_ban, class: 'League::Match::PickBan' do
    association :match, factory: :league_match
    map { nil }
    picked_by { nil }
    kind { :pick }
    team { :home_team }
  end
end
