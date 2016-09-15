require 'rails_helper'

describe 'forums/topics/show' do
  let(:topic) { build_stubbed(:forums_topic) }
  let(:threads) { build_stubbed_list(:forums_thread, 5, topic: topic) }
  let(:subtopics) { build_stubbed_list(:forums_topic, 5, parent: topic) }

  it 'displays data' do
    allow(view).to receive(:user_can_manage_topic?).and_return(true)
    assign(:topic, topic)
    assign(:threads, threads)
    assign(:subtopics, subtopics)

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
