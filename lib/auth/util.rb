module Auth
  # :reek:UtilityFunction
  module Util
    extend self

    def grant_name(actor, action, subject)
      "action_#{actor}_#{action}_#{subject}"
    end

    def ban_name(actor, action, subject)
      "action_#{actor}_#{action}_#{subject}_bans"
    end

    def get_subject_name(subject)
      return subject if subject.is_a?(Symbol)

      subject_cls = if subject.is_a?(ActiveRecord::Relation)
                      subject.model
                    else
                      subject.class
                    end

      subject_cls.name.underscore.sub('/', '_').to_sym
    end
  end
end
