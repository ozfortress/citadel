require 'rails_helper'
require 'support/shoulda'
require 'support/factory_girl'

describe CompetitionMatch do
  before { create(:competition_match) }

  it { should belong_to(:home_team).class_name('CompetitionRoster') }
  it { should belong_to(:away_team).class_name('CompetitionRoster') }
  it { should have_many(:sets).class_name('CompetitionSet') }

  it { should validate_presence_of(:home_team) }

  it do
    should define_enum_for(:status).with([:pending, :submitted_by_home_team,
                                          :submitted_by_away_team, :confirmed])
  end

  it do
    should define_enum_for(:forfeit_by).with([:no_forfeit, :home_team_forfeit,
                                              :away_team_forfeit])
  end

  it 'should confirm BYE matches' do
    roster = build(:competition_roster)

    expect(CompetitionMatch.new(home_team: roster).status).to eq('confirmed')
  end
end
