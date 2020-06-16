require 'rails_helper'

describe 'forums/show' do
  let(:threads) { build_stubbed_list(:forums_thread, 20) }
  let(:topics) { build_stubbed_list(:forums_topic, 20) }

  it 'displays' do
    threads.each do |thread|
      allow(thread).to receive(:latest_post) { build_stubbed(:forums_post, thread: thread) }
    end

    allow(view).to receive(:user_can_manage_thread?).and_return(true)
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
