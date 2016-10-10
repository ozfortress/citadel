FactoryGirl.define do
  factory :league_roster, class: League::Roster do
    team
    association :division, factory: :league_division
    sequence(:name) { |n| "Immunity #{n}" }
    description 'We beat everyone'
    approved true

    transient do
      player_count 1
      players nil
    end

    after(:build) do |roster, evaluator|
      roster.players = if evaluator.players
                         evaluator.players
                       else
                         build_list(:league_roster_player, evaluator.player_count, roster: roster)
                       end
    end
  end
end
