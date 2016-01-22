require 'support/omniauth'

describe 'routes for user login' do
  describe 'steam' do
    it 'first time' do
      pending('Turn into a Capybara test')

      mock_auth_hash

      expect(get('/users/auth/steam')).to route_to(controller: 'users/omniauth_callbacks', action: 'steam')
    end
  end
end
