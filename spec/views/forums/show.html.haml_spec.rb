require 'rails_helper'

describe 'forums/show' do
  let(:threads) { create_list(:forums_thread, 20) }
  let(:topics) { create_list(:forums_topic, 20) }

  it 'displays' do
    assign(:threads, threads)
    assign(:topics, topics)

    render

    threads.each do |thread|
      expect(rendered).to include(thread.title)
    end
    topics.each do |topic|
      expect(rendered).to include(topic.name)
    end
  end
end
