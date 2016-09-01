require 'rails_helper'

describe 'forums/topics/edit' do
  let(:topic) { create(:forums_topic) }

  it 'displays' do
    assign(:topic, topic)

    render
  end
end
