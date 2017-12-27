FactoryGirl.define do
  factory :league_roster_comment_edit, class: League::Roster::CommentEdit do
    association :created_by, factory: :user
    association :comment, factory: :league_roster_comment
    content 'This team is full of unorganised idiots'
  end
end
