FactoryGirl.define do
  factory :competition_transfer do
    association :roster, factory: :competition_roster
    user
    is_joining true
    approved false

    transient do
      propagate_transfers true
    end

    after(:build) do |transfer, evaluator|
      if evaluator.propagate_transfers
        if !transfer.is_joining? && !transfer.roster.on_roster?(transfer.user)
          create(:competition_transfer, roster: transfer.roster, user: transfer.user, approved: true)
        end

        create(:transfer, team: transfer.roster.team, user: transfer.user,
                          is_joining: true)
      end
    end
  end
end
