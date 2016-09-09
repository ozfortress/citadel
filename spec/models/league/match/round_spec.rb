require 'rails_helper'

describe League::Match::Round do
  before(:all) { create(:league_match_round) }

  it { should belong_to(:map) }
  it { should_not allow_value(nil).for(:map) }

  it { should belong_to(:match).class_name('League::Match') }
  it { should_not allow_value(nil).for(:match) }

  it { should validate_presence_of(:home_team_score) }
  it { should validate_numericality_of(:home_team_score).is_greater_than_or_equal_to(0) }

  it { should validate_presence_of(:away_team_score) }
  it { should validate_numericality_of(:away_team_score).is_greater_than_or_equal_to(0) }

  it "doesn't allows rounds to draw when league doesn't allow it" do
    match = build(:league_match, status: :submitted_by_home_team)
    match.league.allow_round_draws = false

    expect(build(:league_match_round, match: match, home_team_score: 2,
                                      away_team_score: 3)).to be_valid
    expect(build(:league_match_round, match: match, home_team_score: 3,
                                      away_team_score: 2)).to be_valid
    expect(build(:league_match_round, match: match, home_team_score: 2,
                                      away_team_score: 2)).to be_invalid
    expect(build(:league_match_round, match: match, home_team_score: 0,
                                      away_team_score: 0)).to be_invalid
  end

  it 'allows rounds to draw when league allows it' do
    match = build(:league_match, status: :submitted_by_away_team)
    match.league.allow_round_draws = true

    expect(build(:league_match_round, match: match, home_team_score: 2,
                                      away_team_score: 3)).to be_valid
    expect(build(:league_match_round, match: match, home_team_score: 3,
                                      away_team_score: 2)).to be_valid
    expect(build(:league_match_round, match: match, home_team_score: 2,
                                      away_team_score: 2)).to be_valid
    expect(build(:league_match_round, match: match, home_team_score: 0,
                                      away_team_score: 0)).to be_valid
  end
end
