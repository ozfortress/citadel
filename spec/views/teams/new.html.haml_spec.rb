require 'rails_helper'
require 'support/devise'
require 'support/factory_girl'

describe 'teams/new' do
  it 'shows form' do
    assign(:team, Team.new)

    render
  end
end
