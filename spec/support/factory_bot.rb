require 'factory_bot'
require 'support/database_cleaner'

RSpec.configure do |config|
  config.include FactoryBot::Syntax::Methods
end

# Allow rspec mocks in factories
FactoryBot::SyntaxRunner.class_eval do
  include RSpec::Mocks::ExampleMethods
end
