require 'rails_helper'
require 'support/factory_girl'
require 'match_seeder/seeder'

describe MatchSeeder::Swiss do
  # Common test setup code
  def run_seedings(players_count)
    @rounds_count = Math.log2(players_count).ceil

    @div = create(:league_division)
    @rosters = create_list(:league_roster, players_count, division: @div)
    @winners = @rosters.first(10)
    @losers = @rosters.last(10)

    perform_rounds
  end

  def perform_rounds
    round = build(:league_match_round)

    @rounds_count.times do
      described_class.seed_round_for(@div.reload, rounds: [round])

      finalize_matches
    end
  end

  def finalize_matches
    @winners.each do |roster|
      roster.matches.pending.each { |match| match.forfeit(match.home_team != roster) }
    end
    @losers.each do |roster|
      roster.matches.pending.each { |match| match.forfeit(match.home_team == roster) }
    end
    @rosters.each do |roster|
      roster.matches.pending.each { |match| match.update!(status: :confirmed) }
    end
  end

  context 'even number of teams' do
    before do
      run_seedings(30)
    end

    it 'creates matches for all teams' do
      @rosters.each do |roster|
        expect(roster.matches.size).to eq(@rounds_count)
      end
    end

    it 'evenly spreads home and away team matches' do
      @rosters.each do |roster|
        expect(roster.home_team_matches.size).to be_within(2).of(roster.away_team_matches.size)
      end
    end
  end

  context 'odd number of teams' do
    before do
      run_seedings(31)
    end

    it 'creates matches covering all teams' do
      @rosters.each do |roster|
        expect(roster.matches.size).to be_within(1).of(@rounds_count)
      end
    end

    xit 'evenly spreads home and away team matches' do
      @rosters.each do |roster|
        expect(roster.home_team_matches.size).to be_within(2).of(roster.away_team_matches.size)
      end
    end
  end
end
