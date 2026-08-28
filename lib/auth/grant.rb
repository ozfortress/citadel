require 'auth/action_state'

module Auth
  class Grant < ActiveRecord::Base
    self.abstract_class = true
    include ActionState
  end
end
