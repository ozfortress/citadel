require 'rails_helper'

describe Leagues::Matches::GenerationService do
  describe 'single elimination' do
    it 'works' do
      division = create(:league_division)
      league = division.league

      team1 = create(:league_roster, division: division, seeding: 3)
      team2 = create(:league_roster, division: division, seeding: 2)
      team3 = create(:league_roster, division: division, seeding: 1)
      team4 = create(:league_roster, division: division, seeding: 4)

      map = create(:map)
      match_options = {
        round_number: 1, rounds_attributes: [
          { map: map }
        ]
      }
      match = described_class.call(division, match_options, :single_elimination, {})
      expect(match).to be nil

      expect(division.matches.size).to eq(2)
      match1 = division.matches.first
      expect(match1.home_team).to eq(team3)
      expect(match1.away_team).to eq(team4)
      expect(match1.has_winner).to be true
      expect(match1.round_number).to eq(1)
      expect(match1.rounds.size).to eq(1)
      expect(match1.rounds.first.map).to eq(map)
      match2 = division.matches.second
      expect(match2.home_team).to eq(team2)
      expect(match2.away_team).to eq(team1)
      expect(match2.has_winner).to be true
      expect(match2.round_number).to eq(1)
      expect(match2.rounds.size).to eq(1)
      expect(match2.rounds.first.map).to eq(map)

      match1.update!(
        status: :confirmed, rounds_attributes: [
          { id: match1.rounds.first.id, home_team_score: 2, away_team_score: 1 }
        ]
      )
      expect(match1.winner).to eq(team3)

      match2.update!(
        status: :confirmed, rounds_attributes: [
          { id: match2.rounds.first.id, home_team_score: 3, away_team_score: 6 }
        ]
      )
      expect(match2.winner).to eq(team1)

      rosters = division.rosters.ordered(league).to_a
      expect(rosters).to eq([team3, team1, team2, team4])

      map = create(:map)
      match_options = {
        round_number: 2, rounds_attributes: [
          { map: map }
        ]
      }
      match = described_class.call(division, match_options, :single_elimination, round: 1)
      expect(match).to be nil

      expect(division.matches.size).to eq(3)
      division.reload
      match = division.matches.last
      expect(match.home_team).to eq(team3)
      expect(match.away_team).to eq(team1)
      expect(match.round_number).to eq(2)
      expect(match.rounds.size).to eq(1)
      expect(match.rounds.first.map).to eq(map)

      match.update!(
        status: :confirmed, rounds_attributes: [
          { id: match.rounds.first.id, home_team_score: 2, away_team_score: 3 }
        ]
      )
      expect(match.winner).to eq(team1)

      rosters = division.rosters.ordered(league).to_a
      expect(rosters).to eq([team1, team3, team2, team4])
    end

    it 'handles large amount of teams' do
      division = create(:league_division)
      # league = division.league
      map = create(:map)

      create_list(:league_roster, 60, division: division)

      (0...5).each do |round|
        match_options = {
          round_number: round, rounds_attributes: [
            { map: map }
          ]
        }

        invalid = described_class.call(division, match_options, :single_elimination, {})
        expect(invalid).to be nil

        division.matches.pending.find_each do |match|
          score_options = [
            { home_team_score: 3, away_team_score: 2 },
            { home_team_score: 1, away_team_score: 4 },
          ].sample
          match.update!(
            status: :confirmed, rounds_attributes: [
              { id: match.rounds.first.id }.merge(score_options)
            ]
          )
        end
      end
    end
  end
end
