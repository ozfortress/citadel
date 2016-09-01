require 'rails_helper'
require 'support/devise'
require 'support/factory_girl'

describe 'forums/topics/new' do
  let(:topic) { build(:forums_topic, parent_topic: create(:forums_topic)) }

  it 'displays' do
    assign(:topic, topic)

    render
  end
end
