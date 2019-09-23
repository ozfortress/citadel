require 'rails_helper'

describe Forums::Threads::CreationService do
  let(:user) { create(:user) }
  let(:topic) { create(:forums_topic) }
  let(:content) { 'ABCDEFGHIJKLMNOP' }

  it 'succesfully creates a thread' do
    thread = subject.call(user, topic, { title: 'Bar' }, content: content)

    expect(thread).to_not be(nil)
    expect(thread.created_by).to eq(user)
    expect(thread.title).to eq('Bar')
    expect(thread.posts.size).to eq(1)
    post = thread.posts.first
    expect(post.created_by).to eq(user)
    expect(post.content).to eq(content)
  end

  it 'notifies subscribed users' do
    subscribed = create(:user)
    topic.subscriptions.create!(user: subscribed)
    unrelated = create(:user)

    subject.call(user, topic, { title: 'Bar' }, content: content)

    expect(subscribed.notifications.size).to eq(1)
    expect(unrelated.notifications).to be_empty
    expect(user.notifications).to be_empty
  end

  it 'handles invalid thread data' do
    subscribed = create(:user)
    topic.subscriptions.create!(user: subscribed)

    thread = subject.call(user, topic, {}, content: content)

    expect(thread).to be_invalid
    expect(thread.posts.first).to be_valid
    expect(subscribed.notifications).to be_empty
  end

  it 'handles invalid post data' do
    subscribed = create(:user)
    topic.subscriptions.create!(user: subscribed)

    thread = subject.call(user, topic, { title: 'Bar' }, {})

    expect(thread).to be_invalid
    expect(thread.posts.first).to be_invalid
    expect(subscribed.notifications).to be_empty
  end

  it 'handles notifications on hidden isolated topic' do
    topic.update(isolated: true, default_hidden: true)

    subscribed = create(:user)
    topic.subscriptions.create!(user: subscribed)

    admin_subscribed = create(:user)
    admin_subscribed.grant(:manage, topic)
    topic.subscriptions.create!(user: admin_subscribed)

    thread = subject.call(user, topic, { title: 'Bar' }, content: content)

    expect(thread).to be_valid
    expect(thread).to be_isolated
    expect(subscribed.notifications).to be_empty
    expect(admin_subscribed.notifications).to_not be_empty
  end
end
