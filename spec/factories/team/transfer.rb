FactoryGirl.define do
  factory :team_transfer, class: Team::Transfer do
    user
    team
    is_joining true
  end
end
