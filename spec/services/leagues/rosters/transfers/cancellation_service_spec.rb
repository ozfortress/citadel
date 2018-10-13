require 'rails_helper'

describe Leagues::Rosters::Transfers::CancellationService do
  let(:roster) { create(:league_roster) }
  let(:user) { create(:user) }
  let(:transfer_request) { create(:league_roster_transfer_request, roster: roster, user: user) }

  before do
    roster.team.add_player!(user)
  end

  before { ActionMailer::Base.deliveries.clear }

  it 'successfully cancels a transfer request' do
    subject.call(transfer_request, roster)

    expect(transfer_request).to be_destroyed
    expect(roster.transfer_requests).to be_empty
    expect(user.notifications).to_not be_empty
  end
end
