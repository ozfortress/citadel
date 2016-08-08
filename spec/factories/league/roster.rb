FactoryGirl.define do
  factory :league_roster, class: League::Roster do
    team
    association :division, factory: :league_division
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
        roster.transfers = build_list(:league_roster_transfer, evaluator.player_count,
                                      is_joining: true, approved: true, roster: roster)
      end
    end
  end
end
