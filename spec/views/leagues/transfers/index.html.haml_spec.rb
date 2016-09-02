require 'rails_helper'

describe 'leagues/transfers/index' do
  let!(:roster) { create(:league_roster) }
  let!(:approved_transfers) { roster.transfers }
  let!(:pending_transfers) { create_list(:league_roster_transfer, 3, roster: roster) }

  it 'displays all pending transfers' do
    assign(:league, roster.league)

    render

    pending_transfers.each do |transfer|
      expect(rendered).to include(transfer.user.name)
    end

    approved_transfers.each do |transfer|
      expect(rendered).to_not include(transfer.user.name)
    end
  end
end
