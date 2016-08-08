require 'rails_helper'
require 'support/devise'
require 'support/factory_girl'

describe 'leagues/new' do
  it 'displays form' do
    assign(:league, League.new)

    render
  end
end
