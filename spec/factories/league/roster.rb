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
      roster.transfers ||= roster.players.map do |player|
        build(:league_roster_transfer, roster: roster, user: player.user)
      end
    end

    after(:stub) do |roster, evaluator|
      players = if evaluator.players
                  evaluator.players
                else
                  build_stubbed_list(:league_roster_player, evaluator.player_count, roster: roster)
                end
      allow(roster).to receive(:players).and_return(players)
      allow(roster).to receive(:users).and_return(players.map(&:user))
      allow(roster).to receive(:on_roster?) { |user| players.any? { |player| player.user == user } }

      transfers = players.map do |player|
        build_stubbed(:league_roster_transfer, roster: roster, user: player.user)
      end
      allow(roster).to receive(:transfers).and_return(transfers)
    end
  end
end
