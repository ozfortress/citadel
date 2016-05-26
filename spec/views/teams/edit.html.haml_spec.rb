require 'rails_helper'
require 'support/devise'
require 'support/factory_girl'

describe 'teams/edit.html.haml' do
  let(:team) { create(:team) }

  it 'shows form' do
    assign(:team, team)

    render
  end
end
