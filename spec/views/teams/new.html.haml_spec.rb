require 'rails_helper'

describe 'teams/new' do
  it 'shows form' do
    assign(:team, Team.new)

    render
  end
end
