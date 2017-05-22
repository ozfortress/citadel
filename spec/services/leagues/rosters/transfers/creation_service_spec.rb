require 'rails_helper'

describe Leagues::Rosters::Transfers::CreationService do
  let(:roster) { create(:league_roster) }
  let(:user) { create(:user) }
  let(:admin) { create(:user) }

  before do
    roster.team.add_player!(user)
  end

  before { ActionMailer::Base.deliveries.clear }

  it 'successfully creates a transfer request' do
    transfer_request = subject.call(roster, admin, user: user, is_joining: true)

    expect(transfer_request).to be_valid
    expect(roster.transfer_requests).to_not be_empty
  end

  it 'successfully overrides a transfer request when leaving' do
    roster2 = create(:league_roster, division: roster.division)
    roster2.add_player!(user)
    create(:league_roster_transfer_request, roster: roster2, user: user, is_joining: false)

    transfer_request = subject.call(roster, admin, user: user, is_joining: true)

    expect(transfer_request).to be_valid
    expect(roster.transfer_requests).to_not be_empty
    expect(roster2.transfer_requests).to be_empty
  end

  it 'fails with invalid data' do
    transfer_request = subject.call(roster, admin, user: user, is_joining: false)

    expect(transfer_request).to be_invalid
    roster.reload
    expect(roster.transfer_requests).to be_empty
  end
end
