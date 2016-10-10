require 'rails_helper'

describe 'leagues/transfers/index' do
  let(:league) { build_stubbed(:league) }
  let(:transfer_requests) do
    build_stubbed_list(:league_roster_transfer_request, 3)
  end

  it 'displays all pending transfers' do
    assign(:league, league)
    assign(:transfer_requests, transfer_requests)

    render

    transfer_requests.each do |transfer|
      expect(rendered).to include(transfer.user.name)
    end
  end
end
