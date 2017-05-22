require 'rails_helper'

describe 'leagues/transfers/index' do
  let(:league) { build_stubbed(:league) }
  let(:divisions) { build_stubbed_list(:league_division, 3) }

  before do
    pending_transfer_requests = {}
    old_transfer_requests = {}
    divisions.each do |division|
      requests = []
      requests += build_stubbed_list(:league_roster_transfer_request, 3)
      requests += build_stubbed_list(:league_roster_transfer_request, 2, is_joining: false)
      pending_transfer_requests[division] = requests

      requests = [
        build_stubbed(:approved_league_roster_transfer_request),
        build_stubbed(:approved_league_roster_transfer_request, is_joining: false),
        build_stubbed(:denied_league_roster_transfer_request),
        build_stubbed(:denied_league_roster_transfer_request, is_joining: false),
      ]
      old_transfer_requests[division] = requests
    end

    assign(:league, league)
    assign(:divisions, divisions)
    assign(:pending_transfer_requests, pending_transfer_requests)
    assign(:old_transfer_requests, old_transfer_requests)
  end

  it 'displays all pending transfers' do
    render

    divisions.each do |division|
      expect(rendered).to include(division.name)

      division.transfer_requests.each do |transfer|
        expect(rendered).to include(transfer.user.name)
      end
    end
  end
end
