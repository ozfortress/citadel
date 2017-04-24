require 'rails_helper'

describe 'pages/home' do
  let(:user) { create(:user) }

  context 'no news' do
    before do
      assign(:topic, nil)
    end

    it 'renders for unauthenticated user' do
      render
    end

    it 'renders for authenticated user' do
      sign_in user

      render
    end
  end

  context 'with news' do
    before do
      assign(:topic, build_stubbed(:forums_topic))
      threads = build_stubbed_list(:forums_thread, 3)
      assign(:threads, threads)
      assign(:news_posts, threads.map { |thread| [thread, build_stubbed(:forums_post)] }.to_h)
      assign(:more_threads, true)
    end

    it 'renders for unauthenticated user' do
      render
    end

    it 'renders for authenticated user' do
      sign_in user

      render
    end
  end
end
