OmniAuth.config.test_mode = true

RSpec.configure do
  def mock_auth_hash
    OmniAuth.config.mock_auth[:steam] = {
      'provider' => 'steam',
      'uid' => '12345',
      'info' => { 'nickname' => 'foobar' },
    }
  end
end
