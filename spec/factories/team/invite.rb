FactoryBot.define do
  factory :team_invite, class: Team::Invite do
    user
    team
  end
end
