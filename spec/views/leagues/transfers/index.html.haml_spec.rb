require 'rails_helper'

describe 'leagues/transfers/index' do
  let(:league) { build(:league) }
  let(:transfer_requests) do
    build_list(:league_roster_transfer_request, 3)
  end

  it 'displays all pending transfers' do
    assign(:league, league)
    assign(:requests, transfer_requests)

    render

    transfer_requests.each do |transfer|
      expect(rendered).to include(transfer.user.name)
    end
  end
end
