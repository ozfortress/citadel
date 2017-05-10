require 'rails_helper'

describe 'users/show' do
  let(:user) { build(:user, badge_name: 'Admin') }
  let(:teams) { build_stubbed_list(:team, 3) }
  let(:aka) { build_stubbed_list(:user_name_change, 5) }
  let(:titles) { build_stubbed_list(:user_title, 5) }
  let(:team_transfers) { build_stubbed_list(:team_transfer, 5, user: user) }
  let(:team_invites) { build_stubbed_list(:team_invite, 2, user: user) }
  let(:rosters) { build_stubbed_list(:league_roster, 2) }
  let(:matches) { build_stubbed_list(:league_match, 2) }

  before do
    assign(:user, user)
    assign(:teams, teams)
    assign(:aka, aka)
    assign(:titles, titles)
    assign(:team_transfers, team_transfers)
    assign(:team_invites, team_invites)
    assign(:rosters, rosters)
    assign(:matches, matches)

    ban_cls = double(subject: 'Foo')
    bans = []
    bans << double(reason: 'Bad', terminated_at: Time.zone.now, active?: true, class: ban_cls)
    bans << double(reason: nil, terminated_at: Time.zone.now, active?: false, class: ban_cls)
    bans << double(reason: 'Bad', terminated_at: nil, active?: true, class: ban_cls)
    allow(user).to receive(:bans_for).and_return(bans)
  end

  it 'shows public user data' do
    render

    expect(rendered).to include(user.name)
    expect(rendered).to include(user.badge_name)
    # TODO: Add more checks for user data
  end

  it 'shows private user data' do
    allow(view).to receive(:current_user?).and_return(true)

    render

    expect(rendered).to include(user.name)
    expect(rendered).to include(user.badge_name)
    # TODO: Add more checks for user data
  end
end
