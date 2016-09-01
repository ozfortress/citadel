require 'rails_helper'

describe 'forums/topics/new' do
  let(:topic) { build(:forums_topic, parent_topic: create(:forums_topic)) }

  it 'displays' do
    assign(:topic, topic)

    render
  end
end
