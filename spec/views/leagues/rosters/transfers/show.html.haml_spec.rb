require 'rails_helper'

describe 'leagues/rosters/transfers/show' do
  let!(:roster) { build_stubbed(:league_roster) }
  let!(:users_on_roster) { build_stubbed_list(:user, 6) }
  let!(:users_off_roster) { build_stubbed_list(:user, 6) }

  it 'displays all transferable users' do
    assign(:league, roster.league)
    assign(:roster, roster)
    assign(:transfer_request, League::Roster::TransferRequest.new)
    assign(:users_on_roster, users_on_roster)
    assign(:users_off_roster, users_off_roster)

    render

    users_on_roster.each do |user|
      expect(rendered).to include(user.name)
    end

    users_off_roster.each do |user|
      expect(rendered).to include(user.name)
    end
  end
end
