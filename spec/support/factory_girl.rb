require 'factory_girl'
require 'support/database_cleaner'

RSpec.configure do |config|
  config.include FactoryGirl::Syntax::Methods
end
