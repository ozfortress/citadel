require 'rails_helper'

describe 'users/show' do
  let!(:user) { create(:user) }

  before do
    create_list(:team_transfer, 2, user: user)

    transfers = create_list(:league_roster_transfer, 2, user: user, approved: true)
    transfers.each do |transfer|
      transfer.league.update!(status: :running)
    end
    transfers.first.league.update!(signuppable: true)

    create(:league_match, home_team: user.rosters.first)
    create_list(:team_invite, 2, user: user)
    create_list(:user_title, 5, user: user)
  end

  it 'shows public user data' do
    assign(:user, user)

    render

    expect(rendered).to include(user.name)
    # TODO: Add more checks for user data
  end

  it 'shows private user data' do
    assign(:user, user)
    sign_in user

    render

    expect(rendered).to include(user.name)
    # TODO: Add more checks for user data
  end
end
