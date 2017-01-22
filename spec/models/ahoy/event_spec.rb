require 'rails_helper'

describe Ahoy::Event do
  before(:all) { create(:ahoy_event) }

  it { should belong_to(:visit) }
  it { should allow_value(nil).for(:visit) }

  it { should belong_to(:user) }
  it { should allow_value(nil).for(:user) }

  describe '#search' do
    it 'can perform search' do
      user = create(:user)
      ip_events = create_list(:ahoy_event, 5, user: user, ip: '12.34.56.78')
      other = create_list(:ahoy_event, 5, user: user, ip: '34.56')

      expect(Ahoy::Event.search('12.34.56.78')).to eq(ip_events)
      expect(Ahoy::Event.search('')).to_not be_empty
    end
  end
end
