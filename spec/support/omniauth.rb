OmniAuth.config.test_mode = true

module OmniAuth
  def self.mock_auth_hash(options = {})
    OmniAuth.config.mock_auth[:steam] = OmniAuth::AuthHash.new(
      'provider' => 'steam',
      'uid'      => options[:steam_id] || '12345',
      'info'     => { 'nickname' => options[:name] || 'foobar' }
    )
  end

  def self.mock_auth_fail
    OmniAuth.config.mock_auth[:steam] = :invalid_credentials
  end
end
