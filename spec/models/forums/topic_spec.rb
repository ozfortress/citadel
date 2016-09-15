require 'rails_helper'

describe Forums::Topic do
  before(:all) { create(:forums_topic) }

  it { should allow_value(nil).for(:parent) }

  it { should belong_to(:created_by).class_name('User') }
  it { should_not allow_value(nil).for(:created_by) }

  it { should have_many(:threads).dependent(:destroy) }

  it { should validate_presence_of(:name) }
  it { should validate_length_of(:name).is_at_least(1) }
  it { should validate_length_of(:name).is_at_most(128) }

  it 'sets depth of root topic' do
    topic = create(:forums_topic)
    expect(topic.reload.depth).to eq(0)
  end

  it 'sets depth from parent_topic' do
    parent_topic = create(:forums_topic)
    other_topic = create(:forums_topic, parent: parent_topic)

    topic = create(:forums_topic, parent: parent_topic)
    topic.reload
    expect(topic.depth).to eq(1)

    topic.update!(parent: other_topic)
    topic.reload
    expect(topic.depth).to eq(2)
  end

  it 'updates depth of children when moved' do
    topic = create(:forums_topic, parent: nil)
    c_thread = create(:forums_thread, topic: topic)
    c_topic = create(:forums_topic, parent: topic)
    c_topic2 = create(:forums_topic, parent: topic)
    gc_thread = create(:forums_thread, topic: c_topic)
    gc_topic = create(:forums_topic, parent: c_topic2)

    parent_topic = create(:forums_topic)

    topic.update!(parent: parent_topic)

    expect(topic.reload.depth).to eq(1)
    expect(c_thread.reload.depth).to eq(2)
    expect(c_topic.reload.depth).to eq(2)
    expect(c_topic2.reload.depth).to eq(2)
    expect(gc_thread.reload.depth).to eq(3)
    expect(gc_topic.reload.depth).to eq(3)
  end
end
