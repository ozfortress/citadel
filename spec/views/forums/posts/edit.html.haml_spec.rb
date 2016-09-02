require 'rails_helper'

describe 'forums/posts/edit' do
  let(:post) { build_stubbed(:forums_post) }

  it 'displays' do
    assign(:post, post)

    render
  end
end
