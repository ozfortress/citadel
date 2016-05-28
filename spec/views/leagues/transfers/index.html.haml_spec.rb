require 'rails_helper'
require 'support/devise'
require 'support/factory_girl'

describe 'leagues/transfers/index' do
  let!(:roster) { create(:competition_roster) }
  let!(:approved_transfers) { roster.transfers }
  let!(:pending_transfers) { create_list(:competition_transfer, 3, roster: roster) }

  it 'displays all pending transfers' do
    assign(:competition, roster.competition)

    render

    pending_transfers.each do |transfer|
      expect(rendered).to include(transfer.user.name)
    end

    approved_transfers.each do |transfer|
      expect(rendered).to_not include(transfer.user.name)
    end
  end
end
