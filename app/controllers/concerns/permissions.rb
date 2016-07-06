module Permissions
  extend ActiveSupport::Concern

  def target
    if has_subject?
      @subject.to_s.camelize.constantize.find(@target)
    else
      @subject
    end
  end

  def has_subject?
    User.permissions[@action][@subject].has_subject
  end
end
