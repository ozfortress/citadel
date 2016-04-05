require 'auth/migration_helper'

module Auth
  module Model
    def self.included(base)
      base.send :include, InstanceMethods
      base.extend ClassMethods
    end

    module InstanceMethods
      def can?(action, subject)
        !get_permission(action, subject).nil?
      end

      def can_any?(action, subject)
        action_cls = self.class.get_action_class(action, subject)

        actor = self.class.name.underscore

        action_cls.exists?(actor => self)
      end

      def which_can(action, subject)
        action_cls = self.class.get_action_class(action, subject)

        actor = self.class.name.underscore

        subject_id = (subject.to_s + '_id').to_sym
        # TODO: Optimisation
        action_cls.where(actor => self).select(subject_id).map do |i|
          subject.to_s.camelize.constantize.find(i.send(subject_id))
        end
      end

      def grant(action, subject)
        action_cls = self.class.get_action_class(action, subject)

        params = { self.class.name.underscore + '_id' => id }
        params.update(subject.class.name.underscore + '_id' => subject.id) if action_cls.has_subject

        action_cls.create!(params)
      end

      def grant_all
        self.class.permissions.each do |action, subject_hash|
          subject_hash.each do |subject, cls|
            grant(action, subject) unless cls.has_subject
          end
        end
      end

      def revoke(action, subject)
        permission = get_permission(action, subject)

        permission.destroy! unless permission.nil?
      end

      private

      def get_permission(action, subject)
        action_cls = self.class.get_action_class(action, subject)

        actor = self.class.name.underscore
        subj = subject.class.name.underscore

        params = { actor => self }
        params.update(subj => subject) if action_cls.has_subject

        action_cls.find_by(params)
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

        @permissions ||= {}
        @permissions[action] ||= {}
        @permissions[action][subject] = new_permission_model(table, actor, subject)
      end

      attr_reader :permissions

      def get_action_class(action, subject)
        subject = subject.class.name.underscore.to_sym unless subject.class == Symbol

        action_cls = permissions[action][subject]
        throw "Unknown action or subject `#{action}##{subject}`" if action_cls.nil?

        action_cls
      end

      private

      def new_permission_model(table, actor, subject)
        Class.new(ActiveRecord::Base) do
          self.table_name = table
          belongs_to actor

          # Only permissions relating to singular objects have a subject
          class << self
            attr_accessor :has_subject
          end
          self.has_subject = subject.to_s.singularize == subject.to_s
          belongs_to subject if has_subject
        end
      end
    end
  end
end
