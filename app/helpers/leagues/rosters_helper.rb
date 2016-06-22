module Leagues
  module RostersHelper
    include RosterPermissions
    include TransferPermissions

    def roster_destroy_confirm
      if @competition.signuppable?
        'Are you sure you want to remove the signup for this roster?'
      else
        'Are you sure you want to disband this roster?'
      end
    end

    def roster_destroy_label
      if @competition.signuppable?
        'Remove Signup'
      else
        'Disband'
      end
    end
  end
end
