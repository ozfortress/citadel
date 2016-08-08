FactoryGirl.define do
  factory :league_roster_transfer, class: League::Roster::Transfer do
    user
    association :roster, factory: :league_roster
    is_joining true
    approved false

    transient do
      propagate_transfers true
    end

    after(:build) do |transfer, evaluator|
      if evaluator.propagate_transfers
        if !transfer.is_joining? && !transfer.roster.on_roster?(transfer.user)
          create(:league_roster_transfer, roster: transfer.roster,
                                          user: transfer.user, approved: true)
        end

        create(:team_transfer, team: transfer.roster.team, user: transfer.user,
                               is_joining: true)
      end
    end
  end
end
