FactoryBot.define do
  factory :league_roster_transfer, class: League::Roster::Transfer do
    user
    association :roster, factory: :league_roster
    is_joining { true }
  end
end
