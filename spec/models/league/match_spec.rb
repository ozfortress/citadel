require 'rails_helper'

describe League::Match do
  before(:all) { create(:league_match) }

  it { should belong_to(:home_team).class_name('League::Roster') }
  it { should_not allow_value(nil).for(:home_team) }

  it { should belong_to(:away_team).class_name('League::Roster') }
  it { should allow_value(nil).for(:away_team) }

  it { should have_many(:rounds).class_name('Match::Round').dependent(:destroy) }
  it { should accept_nested_attributes_for(:rounds) }

  it { should have_many(:pick_bans).class_name('Match::PickBan').dependent(:destroy) }
  it { should accept_nested_attributes_for(:pick_bans) }

  it { should have_many(:comms).class_name('Match::Comm').dependent(:destroy) }

  it { should validate_numericality_of(:round_number).is_greater_than_or_equal_to(0) }
  it { should allow_value(nil).for(:round_number) }

  it { should allow_value('').for(:round_name) }
  it { should validate_length_of(:round_name).is_at_least(0) }

  it { should allow_value('').for(:notice) }
  it { should validate_length_of(:notice).is_at_least(0) }

  it do
    should define_enum_for(:status).with([:pending, :submitted_by_home_team,
                                          :submitted_by_away_team, :confirmed])
  end

  it do
    should define_enum_for(:forfeit_by).with([:no_forfeit, :home_team_forfeit,
                                              :away_team_forfeit, :mutual_forfeit,
                                              :technical_forfeit])
  end

  it 'allows creating BYE matches with tied scores' do
    round = build(:league_match_round)
    match = build(:bye_league_match, rounds: [round])
    match.league.update!(allow_round_draws: false)

    expect(match.rounds).to_not be_empty
    expect(match).to be_valid
    expect(match.rounds).to be_empty
  end

  it 'should confirm BYE matches' do
    roster = build(:league_roster)

    expect(League::Match.new(home_team: roster).status).to eq('confirmed')
  end
end
