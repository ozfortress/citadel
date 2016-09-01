require 'auth/test'

RSpec.configure do |config|
  config.include Auth::Test::Helpers, type: :view
end
