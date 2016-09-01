require 'rails_helper'

describe 'forums/threads/show' do
  let(:thread) { create(:forums_thread) }
  let(:posts) { create_list(:forums_post, 20, thread: thread) }

  it 'displays data' do
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
