require 'rails_helper'
require 'support/devise'
require 'support/factory_girl'

describe 'forums/posts/edit' do
  let(:post) { create(:forums_post) }

  it 'displays' do
    assign(:post, post)

    render
  end
end
