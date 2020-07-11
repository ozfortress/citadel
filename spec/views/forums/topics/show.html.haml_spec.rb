require 'rails_helper'

describe 'forums/topics/show' do
  let(:topic) { build_stubbed(:forums_topic) }
  let(:threads) { build_stubbed_list(:forums_thread, 5, topic: topic) }
  let(:subtopics) { build_stubbed_list(:forums_topic, 5, parent: topic) }

  it 'displays data' do
    threads.each do |thread|
      allow(thread).to receive(:latest_post) { build_stubbed(:forums_post, thread: thread) }
    end

    allow(view).to receive(:user_can_manage_topic?).and_return(true)
    assign(:topic, topic)
    assign(:threads, threads.paginate(page: 1))
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
