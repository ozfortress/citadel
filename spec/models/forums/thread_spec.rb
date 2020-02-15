require 'rails_helper'

describe Forums::Thread do
  before(:all) { create(:forums_thread) }

  it { should belong_to(:topic).inverse_of(:threads).optional }

  it { should belong_to(:created_by).class_name('User') }

  it { should have_many(:posts).dependent(:destroy) }

  it { should have_many(:subscriptions).dependent(:destroy) }

  it { should validate_presence_of(:title) }
  it { should validate_length_of(:title).is_at_least(1) }
  it { should validate_length_of(:title).is_at_most(128) }

  it 'sets depth from topic' do
    topic = create(:forums_topic)
    other_topic = create(:forums_topic, parent: topic)

    thread = create(:forums_thread, topic: topic)
    thread.reload
    expect(thread.depth).to eq(1)

    thread.update!(topic: other_topic)
    thread.reload
    expect(thread.depth).to eq(2)
  end

  describe '#set_defaults' do
    it 'defaults to public, unlocked' do
      thread = Forums::Thread.new
      expect(thread.locked?).to be(false)
      expect(thread.pinned?).to be(false)
      expect(thread.hidden?).to be(false)
    end

    it 'inherits hidden and pinned' do
      topic = build(:forums_topic, hidden: true, locked: true)

      thread = Forums::Thread.new(topic: topic)
      expect(thread.locked?).to be(false)
      expect(thread.pinned?).to be(false)
      expect(thread.hidden?).to be(true)
    end

    it 'respects default hidden' do
      topic = build(:forums_topic, hidden: false, default_hidden: true)

      thread = Forums::Thread.new(topic: topic)
      expect(thread.locked?).to be(false)
      expect(thread.pinned?).to be(false)
      expect(thread.hidden?).to be(true)
    end

    it 'respects default locked' do
      topic = build(:forums_topic, default_locked: true, locked: false)

      thread = Forums::Thread.new(topic: topic)
      expect(thread.locked?).to be(true)
      expect(thread.pinned?).to be(false)
      expect(thread.hidden?).to be(false)
    end
  end
end
