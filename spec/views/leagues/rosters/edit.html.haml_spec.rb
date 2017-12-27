require 'rails_helper'

describe 'leagues/rosters/edit' do
  let(:roster) { build_stubbed(:league_roster) }
  let(:users_on_roster) { build_stubbed_list(:user, 6) }
  let(:users_off_roster) { build_stubbed_list(:user, 6) }

  let(:admin) { build_stubbed(:user) }
  let(:comments) do
    build_stubbed_list(:league_roster_comment, 3) +
      build_stubbed_list(:league_roster_comment, 3, deleted_by: admin, deleted_at: Time.zone.now)
  end

  before do
    assign(:league, roster.league)
    assign(:roster, roster)
    assign(:comment, League::Roster::Comment.new)
    assign(:comments, comments)
    assign(:transfer_request, League::Roster::TransferRequest.new)
    assign(:users_on_roster, users_on_roster)
    assign(:users_off_roster, users_off_roster)
  end

  context 'signuppable league' do
    before do
      roster.league.signuppable = true
    end

    it 'displays form for captains' do
      allow(view).to receive(:user_can_disband_roster?).and_return(true)

      render
    end

    it 'displays form for admins' do
      allow(view).to receive(:user_can_edit_league?).and_return(true)
      allow(view).to receive(:user_can_destroy_roster?).and_return(true)

      render
    end
  end

  context 'running league' do
    it 'displays form for captains' do
      allow(view).to receive(:user_can_disband_roster?).and_return(true)

      render
    end

    it 'displays form for admins' do
      allow(view).to receive(:user_can_edit_league?).and_return(true)
      allow(view).to receive(:user_can_destroy_roster?).and_return(true)

      render
    end
  end
end
