require 'rails_helper'

describe User::Log do
  it { should belong_to(:user) }

  describe '.log_user!' do
    it 'creates and updates logs' do
      user = create(:user)
      time1 = Time.zone.parse('1999-01-01')
      allow(Time).to receive(:now).and_return(time1)

      described_class.log_user!(user, '127.0.0.1')

      expect(described_class.count).to eq(1)
      log1 = described_class.first
      expect(log1.user_id).to eq(user.id)
      expect(log1.ip.to_s).to eq('127.0.0.1')
      expect(log1.first_seen_at).to eq(time1)
      expect(log1.last_seen_at).to eq(time1)

      time2 = time1 + 12.days
      allow(Time).to receive(:now).and_return(time2)

      described_class.log_user!(user, '127.0.0.2')

      expect(described_class.count).to eq(2)
      log2 = described_class.second
      expect(log2.user_id).to eq(user.id)
      expect(log2.ip.to_s).to eq('127.0.0.2')
      expect(log2.first_seen_at).to eq(time2)
      expect(log2.last_seen_at).to eq(time2)

      described_class.log_user!(user, '127.0.0.1')

      expect(described_class.count).to eq(2)
      log1.reload
      expect(log1.user_id).to eq(user.id)
      expect(log1.ip.to_s).to eq('127.0.0.1')
      expect(log1.first_seen_at).to eq(time1)
      expect(log1.last_seen_at).to eq(time2)
    end
  end
end
