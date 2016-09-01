require 'rails_helper'

describe 'forums/posts/edit' do
  let(:post) { create(:forums_post) }

  it 'displays' do
    assign(:post, post)

    render
  end
end
