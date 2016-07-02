FactoryGirl.define do
  factory :competition_roster_comment do
    user
    association :roster, factory: :competition_roster
    content 'This team is full of unorganised idiots'
  end
end
