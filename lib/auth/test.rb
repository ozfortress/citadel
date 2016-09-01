module Auth
  module Test
    module Helpers
      def stub_auth(user, action, subject)
        allow(user).to receive(:can?) { |a, s| a ==action && s == subject }
      end
    end
  end
end
