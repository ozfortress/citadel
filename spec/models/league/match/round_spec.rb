require 'rails_helper'

describe League::Match::Round do
  before(:all) { create(:league_match_round) }

  it { should belong_to(:map) }

  it { should belong_to(:match).class_name('League::Match') }

  it { should belong_to(:winner).class_name('League::Roster').optional }

  it { should belong_to(:loser).class_name('League::Roster').optional }

  it { should validate_presence_of(:home_team_score) }
  it { should validate_numericality_of(:home_team_score).is_greater_than_or_equal_to(0) }

  it { should validate_presence_of(:away_team_score) }
  it { should validate_numericality_of(:away_team_score).is_greater_than_or_equal_to(0) }

  def build_round(match, home_team_score, away_team_score)
    build(:league_match_round, match: match, home_team_score: home_team_score, away_team_score: away_team_score,
                               has_outcome: true)
  end

  describe 'validation' do
    it 'validates no round draws allowed' do
      match = build(:league_match, status: :submitted_by_home_team, allow_round_draws: false)

      expect(build_round(match, 2, 3)).to be_valid
      expect(build_round(match, 3, 2)).to be_valid
      expect(build_round(match, 2, 2)).to be_invalid
      expect(build_round(match, 0, 0)).to be_invalid
    end

    it 'validates round draws allowed' do
      match = build(:league_match, status: :submitted_by_away_team, allow_round_draws: true)

      expect(build_round(match, 2, 3)).to be_valid
      expect(build_round(match, 3, 2)).to be_valid
      expect(build_round(match, 2, 2)).to be_valid
      expect(build_round(match, 0, 0)).to be_valid
    end
  end

  # rubocop:disable Style/ParallelAssignment
  describe 'calculations' do
    it 'calculates score difference' do
      match = build(:league_match, status: :confirmed, allow_round_draws: true)

      round = build_round(match, 0, 0)

      round.run_callbacks(:save) { true }
      expect(round.score_difference).to eq(0)

      round.home_team_score, round.away_team_score = 1, 0
      round.run_callbacks(:save) { true }
      expect(round.score_difference).to eq(1)

      round.home_team_score, round.away_team_score = 0, 1
      round.run_callbacks(:save) { true }
      expect(round.score_difference).to eq(-1)

      round.home_team_score, round.away_team_score = 3, 5
      round.run_callbacks(:save) { true }
      expect(round.score_difference).to eq(-2)
    end

    it 'calculates winner and loser' do
      match = build(:league_match, status: :confirmed, allow_round_draws: true)
      home_team = match.home_team
      away_team = match.away_team

      round = build_round(match, 0, 0)

      round.run_callbacks(:save) { true }
      expect(round.winner).to be(nil)
      expect(round.loser).to be(nil)

      round.home_team_score, round.away_team_score = 1, 0
      round.run_callbacks(:save) { true }
      expect(round.winner).to eq(home_team)
      expect(round.loser).to eq(away_team)

      round.home_team_score, round.away_team_score = 0, 1
      round.run_callbacks(:save) { true }
      expect(round.winner).to eq(away_team)
      expect(round.loser).to eq(home_team)
    end
  end
  # rubocop:enable Style/ParallelAssignment
end
