require 'rails_helper'
require 'support/devise'
require 'support/factory_girl'

describe 'forums/topics/edit' do
  let(:topic) { create(:forums_topic) }

  it 'displays' do
    assign(:topic, topic)

    render
  end
end
