FactoryGirl.define do
  factory :competition_roster do
    team
    division
    sequence(:name) { |n| "Immunity #{n}" }
    description 'We beat everyone'
    approved true

    transient do
      player_count 1
      transfers nil
    end

    after(:build) do |roster, evaluator|
      if evaluator.transfers
        roster.transfers = evaluator.transfers
      else
        roster.transfers = build_list(:competition_transfer, evaluator.player_count,
                                      roster: roster, is_joining: true, approved: true)
      end
    end
  end
end
