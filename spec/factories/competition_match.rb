FactoryGirl.define do
  factory :competition_match do
    division
    association :home_team, factory: :competition_roster
    association :away_team, factory: :competition_roster
    status :pending

    # transient do
    #   set_count 3
    # end

    # after(:build) do |match, evaluator|
    #   match.sets = build_list(:competition_set, evaluator.set_count, match: match)
    # end
  end
end
