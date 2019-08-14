require 'rails_helper'

describe Forums::Subscription do
  before(:all) { create(:forums_subscription) }

  it { should belong_to(:user) }

  it 'requires either a topic or a thread' do
    expect(build(:forums_subscription, topic: build(:forums_topic), thread: nil)).to be_valid
    expect(build(:forums_subscription, topic: nil, thread: build(:forums_thread))).to be_valid
    expect(build(:forums_subscription, topic: nil, thread: nil)).to be_invalid
  end
end
