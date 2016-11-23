require 'rails_helper'

describe Leagues::Matches::PickBans::SubmissionService do
  let(:map) { create(:map) }
  let(:user) { create(:user) }
  let(:match) { create(:league_match) }
  let(:other_captain) { create(:user) }

  before do
    other_captain.grant(:edit, match.away_team.team)
  end

  it 'successfully submits a pick' do
    pick = create(:league_match_pick_ban, match: match, kind: :pick)

    expect(subject.call(pick, user, map)).to be_truthy
    expect(pick).to be_valid
    expect(user.notifications).to be_empty
    expect(other_captain.notifications).to_not be_empty
  end

  it 'successfully submits a ban' do
    ban = create(:league_match_pick_ban, match: match, kind: :ban)

    expect(subject.call(ban, user, map)).to be_truthy
    expect(ban).to be_valid
    expect(user.notifications).to be_empty
    expect(other_captain.notifications).to_not be_empty
  end

  it 'fails with invalid data' do
    pick = create(:league_match_pick_ban, match: match, kind: :pick)

    expect(subject.call(pick, nil, map)).to be_falsey
    expect(pick).to be_invalid
    expect(user.notifications).to be_empty
    expect(other_captain.notifications).to be_empty
  end
end
