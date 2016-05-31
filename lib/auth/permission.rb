require 'auth/migration_helper'

module Auth
  module Model
    def self.included(base)
      base.send :include, InstanceMethods
      base.extend ClassMethods
    end

    module InstanceMethods
      def can?(action, subject)
        get_permission(action, subject).exists?
      end

      def can_any?(action, subject)
        klass = self.class
        action_cls = klass.get_action_class(action, subject)

        actor = klass.name.underscore

        action_cls.exists?(actor => self)
      end

      def which_can(action, subject)
        klass = self.class
        action_cls = klass.get_action_class(action, subject)

        actor = klass.name.underscore

        subject_s = subject.to_s
        subject_id = (subject_s + '_id').to_sym
        # TODO: Optimisation
        action_cls.where(actor => self).select(subject_id).map do |entry|
          subject_s.camelize.constantize.find(entry.send(subject_id))
        end
      end

      def grant(action, subject)
        klass = self.class
        action_cls = klass.get_action_class(action, subject)

        params = { klass.name.underscore + '_id' => id }
        params.update(subject.class.name.underscore + '_id' => subject.id) if action_cls.has_subject

        action_cls.create!(params)
      end

      #:nocov:
      def grant_all
        subjects = self.class.permissions.values.sum

        subjects.each do |subject, cls|
          grant(action, subject) unless cls.has_subject
        end
      end
      #:nocov:

      def revoke(action, subject)
        get_permission(action, subject).delete_all
      end

      private

      def get_permission(action, subject)
        klass = self.class
        action_cls = klass.get_action_class(action, subject)

        actor = klass.name.underscore
        subj = subject.class.name.underscore

        params = { actor => self }
        params.update(subj => subject) if action_cls.has_subject

        action_cls.where(params)
      end
    end

    module ClassMethods
      def get_revokeable(action, subject)
        action_cls = get_action_class(action, subject)

        subject_name = subject.class.name.underscore

        params = {}
        params.update(subject_name => subject) if action_cls.has_subject

        # Workaround due to wierd ActiveRecord edge case for dynamically created models
        actor_id = (name.underscore + '_id').to_sym
        ids = action_cls.where(params).select(actor_id).to_a.map(&actor_id)
        find(ids)
      end

      def validates_permission_to(action, subject)
        actor = name.underscore.to_sym

        table = Auth.auth_name(actor, action, subject)

        @permissions ||= Hash.new({})
        @permissions[action].update(subject => new_permission_model(table, actor, subject))
      end

      attr_reader :permissions

      def get_action_class(action, subject)
        subject_cls = subject.class
        subject = subject_cls.name.underscore.to_sym unless subject_cls == Symbol

        action_cls = permissions[action][subject]
        throw "Unknown action or subject `#{action}##{subject}`" unless action_cls

        action_cls
      end

      private

      def new_permission_model(table, actor, subject)
        subject_s = subject.to_s

        Class.new(ActiveRecord::Base) do
          self.table_name = table
          belongs_to actor

          # Only permissions relating to singular objects have a subject
          class << self
            attr_reader :has_subject
          end

          @has_subject = subject_s.singularize == subject_s
          belongs_to subject if has_subject
        end
      end
    end
  end
end
