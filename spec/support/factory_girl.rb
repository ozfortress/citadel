require 'factory_girl'
require 'support/database_cleaner'

RSpec.configure do |config|
  config.include FactoryGirl::Syntax::Methods
end

# Allow rspec mocks in factories
FactoryGirl::SyntaxRunner.class_eval do
  include RSpec::Mocks::ExampleMethods
end
