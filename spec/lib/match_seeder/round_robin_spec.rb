require 'rails_helper'

describe MatchSeeder::RoundRobin do
  context 'even number of teams' do
    before(:all) do
      @div = create(:league_division)
      @rosters = create_list(:league_roster, 6, division: @div)
      round = build(:league_match_round)

      5.times do
        described_class.seed_round_for(@div.reload, rounds: [round])
      end
    end

    it 'creates matches covering all teams' do
      @rosters.each do |roster|
        expect(roster.rosters_not_played).to be_empty
      end
    end

    it 'evenly spreads home and away team matches' do
      @rosters.each do |roster|
        expect(roster.home_team_matches.size).to be_within(1).of(roster.away_team_matches.size)
      end
    end
  end

  context 'odd number of teams' do
    before(:all) do
      @div = create(:league_division)
      @rosters = create_list(:league_roster, 5, division: @div)
      round = build(:league_match_round)

      5.times do
        described_class.seed_round_for(@div.reload, rounds: [round])
      end
    end

    it 'creates matches covering all teams' do
      @rosters.each do |roster|
        expect(roster.rosters_not_played).to be_empty
      end
    end

    it 'evenly spreads home and away team matches' do
      pending
      @rosters.each do |roster|
        expect(roster.home_team_matches.size).to be_within(1).of(roster.away_team_matches.size)
      end
    end
  end
end
