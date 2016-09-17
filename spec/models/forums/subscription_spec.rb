require 'rails_helper'

describe Forums::Subscription do
  before(:all) { create(:forums_subscription) }

  it { should belong_to(:user) }
  it { should_not allow_value(nil).for(:user) }

  it { should belong_to(:topic) }

  it { should belong_to(:thread) }

  it 'requires either a topic or a thread' do
    expect(build(:forums_subscription, topic: nil, thread: nil)).to be_invalid
  end
end
