require 'rails_helper'

describe Forums::Thread do
  before(:all) { create(:forums_thread) }

  it { should belong_to(:topic) }
  it { should allow_value(nil).for(:topic) }

  it { should belong_to(:created_by).class_name('User') }
  it { should_not allow_value(nil).for(:created_by) }

  it { should have_many(:posts).dependent(:destroy) }

  it { should validate_presence_of(:title) }
  it { should validate_length_of(:title).is_at_least(1) }
  it { should validate_length_of(:title).is_at_most(128) }

  it 'sets depth from topic' do
    topic = create(:forums_topic)
    topic.update!(depth: 12)
    other_topic = create(:forums_topic)
    other_topic.update!(depth: 3)

    thread = create(:forums_thread, topic: topic)
    thread.reload
    expect(thread.depth).to eq(13)

    thread.update!(topic: other_topic)
    thread.reload
    expect(thread.depth).to eq(4)
  end
end
