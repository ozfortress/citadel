require 'rails_helper'
require 'support/shoulda'
require 'support/factory_girl'

describe CompetitionRoster do
  before { create(:competition_roster) }

  it { should belong_to(:team) }
  it { should belong_to(:division) }
  it { should have_many(:transfers).class_name('CompetitionTransfer') }
  it { should have_many(:home_team_matches).class_name('CompetitionMatch') }
  it { should have_many(:away_team_matches).class_name('CompetitionMatch') }
  it { should have_many(:comments).class_name('CompetitionRosterComment') }
  it { should have_many(:titles) }

  it { should validate_presence_of(:team) }
  it { should validate_uniqueness_of(:team).scoped_to(:division_id) }
  it { should validate_presence_of(:division) }

  it { should validate_presence_of(:name) }
  it { should validate_uniqueness_of(:name).scoped_to(:division_id) }
  it { should validate_length_of(:name).is_at_least(1) }
  it { should validate_length_of(:name).is_at_most(64) }

  it { should allow_value('').for(:description) }
  it { should validate_length_of(:description).is_at_least(0) }

  it { should allow_value(nil).for(:ranking) }
  it { should validate_numericality_of(:ranking).is_greater_than(0) }

  it { should allow_value(nil).for(:seeding) }
  it { should validate_numericality_of(:seeding).is_greater_than(0) }

  describe 'player count limits' do
    it 'validates minimum players' do
      comp = create(:competition, min_players: 1)
      div = create(:division, competition: comp)

      expect(build(:competition_roster, division: div, player_count: 1)).to be_valid
      expect(build(:competition_roster, division: div, player_count: 5)).to be_valid
      expect(build(:competition_roster, division: div, player_count: 0)).not_to be_valid
    end

    it 'validates maximum players' do
      comp = create(:competition, min_players: 1, max_players: 2)
      div = create(:division, competition: comp)

      expect(build(:competition_roster, division: div, player_count: 1)).to be_valid
      expect(build(:competition_roster, division: div, player_count: 2)).to be_valid
      expect(build(:competition_roster, division: div, player_count: 3)).not_to be_valid
      expect(build(:competition_roster, division: div, player_count: 5)).not_to be_valid
    end

    it 'validates no maximum on players' do
      comp = create(:competition, min_players: 1, max_players: 0)
      div = create(:division, competition: comp)

      expect(build(:competition_roster, division: div, player_count: 1)).to be_valid
      expect(build(:competition_roster, division: div, player_count: 10)).to be_valid
      expect(build(:competition_roster, division: div, player_count: 20)).to be_valid
    end
  end

  describe '#matches' do
    it 'returns both home and away matches' do
      roster = create(:competition_roster)
      home_match = create(:competition_match, home_team: roster)
      away_match = create(:competition_match, away_team: roster)

      expect(roster.home_team_matches).to eq([home_match])
      expect(roster.away_team_matches).to eq([away_match])
      expect(roster.matches).to include(home_match)
      expect(roster.matches).to include(away_match)
    end
  end

  describe '#disband' do
    it 'forfeits all matches' do
      roster = create(:competition_roster)
      home_match = create(:competition_match, home_team: roster)
      away_match = create(:competition_match, away_team: roster)

      roster.disband

      expect(home_match.reload.forfeit_by).to eq('home_team_forfeit')
      expect(away_match.reload.forfeit_by).to eq('away_team_forfeit')
    end
  end
end
