require 'rails_helper'

describe 'teams/edit' do
  let(:user) { create(:user) }
  let(:team) { create(:team) }

  it 'shows form for captain' do
    user.grant(:edit, team)
    sign_in user
    assign(:team, team)

    render
  end

  it 'shows form for admin' do
    user.grant(:edit, :teams)
    sign_in user
    assign(:team, team)

    render
  end
end
