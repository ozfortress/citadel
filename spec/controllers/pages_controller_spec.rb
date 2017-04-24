require 'rails_helper'

describe PagesController do
  describe 'GET #home' do
    it 'returns http success' do
      Rails.configuration.news['type'] = 'none'

      get :home

      expect(response).to have_http_status(:success)
    end
  end
end
