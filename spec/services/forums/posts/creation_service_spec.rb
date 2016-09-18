require 'rails_helper'

describe Forums::Posts::CreationService do
  let(:user) { create(:user) }
  let(:thread) { create(:forums_thread) }

  it 'succesfully creates a post' do
    post = subject.call(user, thread, content: 'Foo')

    expect(post).to_not be(nil)
    expect(post.created_by).to eq(user)
    expect(post.content).to eq('Foo')
  end

  it 'notifies subscribed users' do
    subscribed = create(:user)
    thread.subscriptions.create!(user: subscribed)
    unrelated = create(:user)

    subject.call(user, thread, content: 'Foo')

    expect(subscribed.notifications.size).to eq(1)
    expect(unrelated.notifications).to be_empty
    expect(user.notifications).to be_empty
  end

  it 'handles invalid data' do
    subscribed = create(:user)
    thread.subscriptions.create!(user: subscribed)

    post = subject.call(user, thread, {})

    expect(post).to be_invalid
    expect(subscribed.notifications).to be_empty
  end
end
