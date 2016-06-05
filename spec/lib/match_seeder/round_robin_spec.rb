require 'rails_helper'
require 'support/factory_girl'
require 'match_seeder/seeder'

describe MatchSeeder::RoundRobin do
  context 'even number of teams' do
    before do
      @div = create(:division)
      @rosters = create_list(:competition_roster, 6, division: @div)
      set = build(:competition_set)

      5.times do
        described_class.seed_round_for(@div.reload, sets: [set])
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
    before do
      @div = create(:division)
      @rosters = create_list(:competition_roster, 5, division: @div)
      set = build(:competition_set)

      5.times do
        described_class.seed_round_for(@div.reload, sets: [set])
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
