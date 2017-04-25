require 'rails_helper'

describe ErrorsController do
  describe 'GET #not_found' do
    it 'returns http not_foudn' do
      get :not_found

      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'GET #internal_server_error' do
    it 'returns http internal_server_error' do
      get :internal_server_error

      expect(response).to have_http_status(:internal_server_error)
    end
  end
end
