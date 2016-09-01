require 'rails_helper'

describe 'leagues/new' do
  it 'displays form' do
    assign(:league, League.new)

    render
  end
end
