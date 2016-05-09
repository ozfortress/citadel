require 'rails_helper'
require 'support/devise'
require 'support/factory_girl'

describe 'users/show.html.haml' do
  let(:user) { create(:user) }

  before do
    create_list(:transfer, 2, user: user)
    create_list(:competition_transfer, 2, user: user)
    create(:competition_match, home_team: user.rosters.first)
    create_list(:team_invite, 2, user: user)
  end

  it 'shows user data' do
    assign(:user, user)

    render

    expect(rendered).to include(user.name)
    # TODO: Add more checks for user data
  end
end
