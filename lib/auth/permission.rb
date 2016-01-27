require 'auth/migration_helper'

module Auth
  module Model
    extend ActiveSupport::Concern

    def can?(action, subject)
      subject_name = subject.class.name.to_sym

      permission = @permissions[action][subject_name]
      throw 'Unknown action or subject' unless permission

      actor = self.class.name.underscore

      params = { actor => self }
      params.update(subject_name => subject) if permission.has_subject

      !permission.find_by(params).nil?
    end

    class_methods do
      attr_accessor :permissions

      def validates_permission_to(action, subject)
        actor = name.underscore.to_sym

        table_name = Auth.auth_name(actor, action, subject)

        klass = Class.new(ActiveRecord::Base)

        klass.class_eval do
          self.table_name = table_name
          belongs_to actor

          has_subject = subject.to_s.singularize == subject
          belongs_to subject if has_subject
        end

        @permissions ||= {}
        @permissions[action] ||= {}
        @permissions[action][subject] = klass
      end
    end
  end
end
