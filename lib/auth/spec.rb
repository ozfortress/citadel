module Shoulda
  module Matchers
    module ActiveModel
      def validate_permission_to(action, subject)
        ValidatePermissionToMatcher.new(action, subject)
      end

      class ValidatePermissionToMatcher < ValidationMatcher
        def initialize(action, subject)
          @action = action
          @subject = subject
        end

        def permission_exists?
          @actor.respond_to?(:permissions) &&
          @actor.permissions.has_key?(@action) &&
          @actor.permissions[@action].has_key?(@subject)
        end

        def matches?(actor)
          @actor = actor
          true
        end
      end
    end
  end
end
