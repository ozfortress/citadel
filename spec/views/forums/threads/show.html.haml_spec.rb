require 'rails_helper'

describe 'forums/threads/show' do
  let(:thread) { build_stubbed(:forums_thread) }
  let(:posts) { build_stubbed_list(:forums_post, 20, thread: thread) }

  it 'displays data' do
    allow(view).to receive(:user_can_manage_thread?).and_return(true)
    assign(:thread, thread)
    assign(:posts, posts)
    assign(:post, build(:forums_post))

    render

    expect(rendered).to include(thread.title)
    thread.posts.each do |post|
      expect(rendered).to include(post.created_by.name)
      expect(rendered).to include(post.content)
    end
  end
end
