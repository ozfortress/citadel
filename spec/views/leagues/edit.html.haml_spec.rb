require 'rails_helper'
require 'support/devise'
require 'support/factory_girl'

describe 'leagues/edit' do
  let(:league) { create(:league) }

  it 'displays form' do
    assign(:league, league)

    render
  end
end
