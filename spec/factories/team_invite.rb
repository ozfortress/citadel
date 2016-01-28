FactoryGirl.define do
  factory :team_invite do
    user { User.first || create(:user) }
    team { Team.first || create(:team) }
  end
end
