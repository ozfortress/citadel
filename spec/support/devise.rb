require 'devise'

module Devise
  module Test
    module ViewHelpers
      def sign_in(user)
        allow(view).to receive(:user_signed_in?) { true }
        allow(view).to receive(:current_user) { user }
      end
    end
  end
end

RSpec.configure do |config|
  config.include Devise::Test::ControllerHelpers, type: :controller
  config.include Devise::Test::ViewHelpers, type: :view
end
