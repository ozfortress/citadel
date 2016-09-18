require 'rails_helper'

describe 'forums/threads/edit' do
  let(:thread) { build_stubbed(:forums_thread) }

  it 'displays' do
    allow(view).to receive(:user_can_manage_thread?).and_return(true)
    assign(:thread, thread)

    render
  end
end
