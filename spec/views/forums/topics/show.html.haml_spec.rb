require 'rails_helper'

describe 'forums/topics/show' do
  let(:topic) { create(:forums_topic) }
  let(:subtopics) { create_list(:forums_topic, 5, parent_topic: topic) }
  let(:threads) { create_list(:forums_thread, 5, topic: topic) }

  it 'displays data' do
    assign(:topic, topic)
    assign(:subtopics, subtopics)
    assign(:threads, threads)

    render

    expect(rendered).to include(topic.name)
    threads.each do |thread|
      expect(rendered).to include(thread.title)
    end
    subtopics.each do |topic|
      expect(rendered).to include(topic.name)
    end
  end
end
