require 'rails_helper'
require 'support/devise'
require 'support/factory_girl'

describe 'forums/threads/edit' do
  let(:thread) { create(:forums_thread) }

  it 'displays' do
    assign(:thread, thread)

    render
  end
end
