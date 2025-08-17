require 'rails_helper'

describe Users::OmniauthCallbacksController do
  describe 'POST #discord' do
    let(:user) { create(:user) }
    let(:discord_id) { 123 }

    before do
      allow(Rails.configuration.features).to receive(:discord_integration).and_return(true)
      sign_in user
      OmniAuth.config.add_mock(
        :discord,
        extra:       { raw_info: { 'id' => discord_id } },
        credentials: { token: 1234 }
      )
      request.env['devise.mapping'] = Devise.mappings[:user]
      request.env['omniauth.auth'] = OmniAuth.config.mock_auth[:discord]
    end

    it 'allows users to link a Discord account' do
      post :discord
      user.reload
      expect(user.discord_id).to eq(discord_id)
    end

    let(:second_user) { create(:user_with_discord) }
    it 'enforces Discord account uniqueness' do
      expect(user.discord_id).to_not eq(second_user.discord_id)
      request.env['omniauth.auth'].extra.raw_info['id'] = second_user.discord_id
      post :discord
      user.reload
      expect(user.discord_id).to_not eq(second_user.discord_id)
    end
  end
end
