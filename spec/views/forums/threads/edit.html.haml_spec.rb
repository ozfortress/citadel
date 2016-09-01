require 'rails_helper'

describe 'forums/threads/edit' do
  let(:thread) { build_stubbed(:forums_thread) }

  it 'displays' do
    assign(:thread, thread)

    render
  end
end
