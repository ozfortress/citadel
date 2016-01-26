OmniAuth.config.test_mode = true

RSpec.configure do
  def mock_auth_hash(options = {})
    OmniAuth.config.mock_auth[:steam] = OmniAuth::AuthHash.new({
      'provider' => 'steam',
      'uid'      => options[:steam_id] || '12345',
      'info'     => {'nickname' => options[:name] || 'foobar' },
    })
  end
end
