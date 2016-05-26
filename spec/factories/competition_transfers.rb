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
      if evaluator.roster && evaluator.propagate_transfers
        create(:transfer, team: evaluator.roster.team, user: transfer.user,
                          is_joining: transfer.is_joining)
      end
    end
  end
end
