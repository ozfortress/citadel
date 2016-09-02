require 'rails_helper'

describe 'leagues/edit' do
  let(:league) { create(:league) }

  it 'displays form' do
    assign(:league, league)

    render
  end
end
