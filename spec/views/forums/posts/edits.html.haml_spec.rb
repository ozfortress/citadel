require 'rails_helper'

describe 'forums/posts/edits' do
  let(:post) { build_stubbed(:forums_post) }
  let(:edits) { build_stubbed_list(:forums_post_edit, 5, post: post) }

  it 'displays' do
    assign(:post, post)
    assign(:edits, edits.paginate(page: 1))

    render
  end
end
