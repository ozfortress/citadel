require 'rails_helper'

describe ForumsController do
  let!(:topics) { create_list(:forums_topic, 10) }
  let!(:threads) { create_list(:forums_thread, 10, topic: nil) }

  describe 'GET #show' do
    it 'displays' do
      get :show

      expect(response).to have_http_status(:success)
    end
  end
end
