require 'rails_helper'

describe SteamController do
  describe 'GET #show' do
    let(:user) { create(:user) }

    it 'succeeds' do
      get :show, params: { id: user.steam_id }

      expect(response).to redirect_to(user_path(user))
    end
  end
end
