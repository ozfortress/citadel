require 'auth/action_state'

module Auth
  class Grant < ActiveRecord::Base
    include ActionState
  end
end
