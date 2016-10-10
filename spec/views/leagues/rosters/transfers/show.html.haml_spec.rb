require 'rails_helper'

describe 'leagues/rosters/transfers/show' do
  let!(:roster) { create(:league_roster) }
  let!(:approved_transfers) { roster.transfers }
  let!(:pending_transfers) { create_list(:league_roster_transfer, 3, roster: roster) }

  it 'displays all transferable users' do
    assign(:league, roster.league)
    assign(:roster, roster)
    assign(:transfer_request, League::Roster::TransferRequest.new)

    render

    roster.users.each do |user|
      expect(rendered).to include(user.name)
    end

    roster.users_off_roster.each do |user|
      expect(rendered).to include(user.name)
    end

    # TODO: Ensure correct buttons are disabled
  end
end
