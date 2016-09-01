require 'rails_helper'
require 'support/devise'
require 'support/factory_girl'

describe 'forums/threads/new' do
  let(:thread) { build(:forums_thread, topic: create(:forums_topic)) }

  it 'displays' do
    assign(:thread, thread)

    render
  end
end
