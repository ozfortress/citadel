require 'rails_helper'

describe Ahoy::Event do
  before(:all) { create(:ahoy_event) }

  it { should belong_to(:visit) }
  it { should allow_value(nil).for(:visit) }

  describe '#search' do
    it 'can perform search' do
      user = create(:user)
      ip_visit = create(:visit, user: user, ip: '12.34.56.78')
      ip_events = create_list(:ahoy_event, 5, visit: ip_visit)
      create_list(:ahoy_event, 5)

      expect(Ahoy::Event.search('12.34.56.78')).to eq(ip_events)
      expect(Ahoy::Event.search('').count).to be >= 10
    end
  end
end
