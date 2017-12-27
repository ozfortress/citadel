FactoryGirl.define do
  factory :league_match_comm, class: League::Match::Comm do
    association :created_by, factory: :user
    deleted_at Time.zone.now
    association :match, factory: :league_match
    sequence(:content) { |n| "Can we play at #{n}:00" }
  end
end
