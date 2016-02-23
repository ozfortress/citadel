FactoryGirl.define do
  factory :competition_roster do
    team
    division
    sequence(:name) { |n| "Immunity #{n}" }
    description 'We beat everyone'
    approved true

    transient do
      player_count 6
    end

    after(:build) do |roster, evaluator|
      roster.transfers = build_list(:competition_transfer, evaluator.player_count,
                                    roster: roster, is_joining: true)
    end
  end
end
