module Forums
  module Permissions
    extend ActiveSupport::Concern

    def user_can_manage_forums?
      user_signed_in? && current_user.can?(:manage, :forums)
    end
  end
end
