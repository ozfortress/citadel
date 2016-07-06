module Permissions
  extend ActiveSupport::Concern

  def target
    if subject?
      @subject.to_s.camelize.constantize.find(@target)
    else
      @subject
    end
  end

  def subject?
    User.permissions[@action][@subject].has_subject
  end
end
