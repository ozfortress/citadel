FactoryGirl.define do
  factory :league_roster_comment, class: League::Roster::Comment do
    user
    association :roster, factory: :league_roster
    content 'This team is full of unorganised idiots'
  end
end
