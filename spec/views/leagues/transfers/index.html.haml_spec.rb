require 'rails_helper'

describe 'leagues/transfers/index' do
  let(:league) { build_stubbed(:league) }
  let(:divisions) { build_stubbed_list(:league_division, 3) }

  before do
    divisions.each do |division|
      requests = []
      requests += build_stubbed_list(:league_roster_transfer_request, 3)
      requests += build_stubbed_list(:league_roster_transfer_request, 2, is_joining: false)
      allow(division).to receive(:transfer_requests).and_return(requests)
    end

    assign(:league, league)
    assign(:divisions, divisions)
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
