require 'rails_helper'

describe 'users/show' do
  let(:user) { build(:user) }
  let(:teams) { build_stubbed_list(:team, 3) }
  let(:team_transfers) { build_stubbed_list(:team_transfer, 5, user: user) }
  let(:team_invites) { build_stubbed_list(:team_invite, 2, user: user) }
  let(:rosters) { build_stubbed_list(:league_roster, 2) }
  let(:matches) { build_stubbed_list(:league_match, 2) }

  before do
    assign(:user, user)
    assign(:teams, teams)
    assign(:team_transfers, team_transfers)
    assign(:team_invites, team_invites)
    assign(:rosters, rosters)
    assign(:matches, matches)
  end

  it 'shows public user data' do
    render

    expect(rendered).to include(user.name)
    # TODO: Add more checks for user data
  end

  it 'shows private user data' do
    allow(view).to receive(:current_user?).and_return(true)

    render

    expect(rendered).to include(user.name)
    # TODO: Add more checks for user data
  end
end
