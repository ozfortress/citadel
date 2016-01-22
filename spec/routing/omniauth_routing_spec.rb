require 'support/omniauth'

describe 'routes for user login' do
  describe 'steam' do
    before do
      # Rails.application.env_config["devise.mapping"] = Devise.mappings[:user] # If using Devise
    end

    describe 'first login' do
      before do
        OmniAuth.config.add_mock(:steam, 'uid' => '12345')
        Rails.application.env_config['omnauth.auth'] = OmniAuth.config.mock_auth[:steam]
        p Rails.application.env_config['omniauth.auth']
      end

      pending it 'redirects to callback' do
        expect(get('/users/auth/steam')).to route_to(controller: 'users/omniauth_callbacks', action: 'steam')
      end
    end
  end
end
