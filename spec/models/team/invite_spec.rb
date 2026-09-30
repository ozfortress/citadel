require 'rails_helper'

describe Team::Invite do
  before do
    allow(Rails.configuration.features).to receive(:team_invite_expiry_days).and_return(7)
  end

  let!(:expired_invite) { create(:team_invite, created_at: 10.days.ago) }
  let!(:invite) { create(:team_invite, created_at: 2.days.ago) }

  it { should belong_to(:user) }
  # it { should validate_uniqueness_of(:user).scoped_to(:team) }

  it { should belong_to(:team) }

  describe '.expiry' do
    it 'uses the configured number of days' do
      allow(Rails.configuration.features).to receive(:team_invite_expiry_days).and_return(3)
      expect(Team::Invite.expiry).to eq(3.days)
    end

    it 'defaults to 1 week if not configured' do
      allow(Rails.configuration.features).to receive(:team_invite_expiry_days).and_return(nil)
      expect(Team::Invite.expiry).to eq(1.week)
    end

    it 'returns nil when invite expiration is set to 0' do
      allow(Rails.configuration.features).to receive(:team_invite_expiry_days).and_return(0)
      expect(Team::Invite.expiry).to be_nil
    end

    it 'returns nil when invite expiration is set to a negative number' do
      allow(Rails.configuration.features).to receive(:team_invite_expiry_days).and_return(-1)
      expect(Team::Invite.expiry).to be_nil
    end
  end

  describe '.active' do
    it 'includes invites that are within the expiry period' do
      expect(Team::Invite.active).to include(invite)
    end

    it 'excludes invites that are older than the expiry period' do
      expect(Team::Invite.active).not_to include(expired_invite)
    end
    context 'when expiry is zero or negative' do
      before do
        allow(Rails.configuration.features).to receive(:team_invite_expiry_days).and_return(0)
      end

      it 'includes all invites' do
        expect(Team::Invite.active).to include(invite, expired_invite)
      end
    end
  end

  describe '.expired' do
    it 'includes invites that are older than the expiry period' do
      expect(Team::Invite.expired).to include(expired_invite)
    end

    it 'excludes invites that are within the expiry period' do
      expect(Team::Invite.expired).not_to include(invite)
    end
    context 'when expiry is zero or negative' do
      before do
        allow(Rails.configuration.features).to receive(:team_invite_expiry_days).and_return(0)
      end

      it 'includes no invites as expired' do
        expect(Team::Invite.expired).to be_empty
      end
    end
  end

  describe '#expired?' do
    it 'returns false when expiry is zero or negative' do
      allow(Rails.configuration.features).to receive(:team_invite_expiry_days).and_return(0)
      expect(invite.expired?).to be false
    end

    it 'returns true when the invite is older than the expiry period' do
      allow(Rails.configuration.features).to receive(:team_invite_expiry_days).and_return(7)
      expect(expired_invite.expired?).to be true
    end

    it 'returns false when the invite is within the expiry period' do
      allow(Rails.configuration.features).to receive(:team_invite_expiry_days).and_return(7)
      expect(invite.expired?).to be false
    end
  end
end
