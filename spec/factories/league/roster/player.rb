FactoryBot.define do
  factory :league_roster_player, class: League::Roster::Player do
    user
    association :roster, factory: :league_roster
  end
end
