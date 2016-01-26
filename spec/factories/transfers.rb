FactoryGirl.define do
  factory :transfer do
    user { User.first || create(:user) }
    team { Team.first || create(:team) }
    is_joining? true
  end
end
