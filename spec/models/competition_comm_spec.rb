require 'rails_helper'
require 'support/shoulda'
require 'support/factory_girl'

describe CompetitionComm do
  before { create(:competition_comm) }

  it { should belong_to(:user) }
  it { should belong_to(:match).class_name('CompetitionMatch') }

  it { should validate_presence_of(:user) }
  it { should validate_presence_of(:match) }
  it { should validate_presence_of(:content) }

  it 'notifies relevant users of a new comm' do
    match = create(:competition_match)
    commer = match.home_team.player_users.first
    commer.notifications.destroy_all
    home_captain = create(:user)
    home_captain.grant(:edit, match.home_team.team)
    away_captain = create(:user)
    away_captain.grant(:edit, match.away_team.team)

    create(:competition_comm, match: match, user: commer)

    expect(commer.notifications).to be_empty
    expect(home_captain.notifications).to_not be_empty
    expect(away_captain.notifications).to_not be_empty
  end
end
