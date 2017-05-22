FactoryGirl.define do
  factory :league_roster_transfer_request, class: League::Roster::TransferRequest do
    association :created_by, factory: :user
    user
    association :roster, factory: :league_roster
    is_joining true

    transient do
      propagate false
    end

    after(:build) do |transfer, evaluator|
      if evaluator.propagate
        user = transfer.user

        roster = transfer.roster
        roster.add_player!(user) if !transfer.is_joining? && !roster.on_roster?(user)

        team = roster.team
        team.add_player!(user) unless team.on_roster?(user)
      end
    end

    factory :approved_league_roster_transfer_request do
      association :approved_by, factory: :user
    end

    factory :denied_league_roster_transfer_request do
      association :denied_by, factory: :user
    end
  end
end
