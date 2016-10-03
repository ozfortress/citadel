require 'auth/migration_helper'

module Auth
  module Model
    def self.included(base)
      base.send :include, InstanceMethods
      base.extend ClassMethods
    end

    module InstanceMethods
      def can?(action, subject)
        @permissions_cache ||= {}
        @permissions_cache[action] ||= {}

        if @permissions_cache[action][subject].nil?
          @permissions_cache[action][subject] = get_permission(action, subject).exists?
        else
          @permissions_cache[action][subject]
        end
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

        subject_name = klass.get_subject_name(subject)
        params.update(subject_name + '_id' => subject.id) if action_cls.has_subject

        action_cls.create!(params)
      end

      def revoke(action, subject)
        get_permission(action, subject).delete_all
      end

      private

      def get_permission(action, subject)
        klass = self.class
        action_cls = klass.get_action_class(action, subject)

        actor = klass.name.underscore
        subj = klass.get_subject_name(subject).to_sym

        params = { actor => self }
        params.update(subj => subject) if action_cls.has_subject

        action_cls.where(params)
      end
    end

    module ClassMethods
      def get_revokeable(action, subject)
        action_cls = get_action_class(action, subject)

        subject_name = get_subject_name(subject).to_sym

        params = {}
        params.update(subject_name => subject) if action_cls.has_subject

        # Workaround due to wierd ActiveRecord edge case for dynamically created models
        actor_id = (name.underscore + '_id').to_sym
        ids = action_cls.where(params).select(actor_id).to_a.map(&actor_id)
        find(ids)
      end

      def validates_permission_to(action, subject, options = {})
        actor = name.underscore.to_sym

        table = Auth.auth_name(actor, action, subject)
        model = new_permission_model(table: table, actor: actor, subject: subject,
                                     subject_options: options)

        @permissions ||= Hash.new { |hash, key| hash[key] = {} }
        @permissions[action].update(subject => model)
        const_set(table.camelize, model)
        assign_subject_relation(subject, model, options[:class_name]) if model.has_subject
      end

      attr_reader :permissions

      def get_action_class(action, subject)
        subject = get_subject_name(subject).to_sym

        action_cls = permissions[action][subject]
        throw "Unknown action or subject `#{action}##{subject}`" unless action_cls

        action_cls
      end

      def get_subject_name(subject)
        return subject if subject.is_a?(Symbol)

        subject_cls = if subject.is_a?(ActiveRecord::Relation)
                        subject.model
                      else
                        subject.class
                      end

        subject_cls.name.underscore.sub('/', '_')
      end

      private

      # Since this method defines a class, we can disable line length checks
      # rubocop:disable Metrics/MethodLength
      def new_permission_model(options)
        subject = options[:subject]
        subject_s = subject.to_s

        Class.new(ActiveRecord::Base) do
          self.table_name = options[:table]
          belongs_to options[:actor]

          # Only permissions relating to singular objects have a subject
          @has_subject = subject_s.singularize == subject_s
          class << self
            attr_reader :has_subject
          end

          belongs_to subject, options[:subject_options] if has_subject
        end
      end
      # rubocop:enable Metrics/MethodLength

      def assign_subject_relation(subject, model, subject_cls)
        association_name = model.table_name.to_sym
        subject_cls ||= subject.to_s.camelize
        subject_cls = subject_cls.constantize

        subject_cls.has_many association_name, class_name: model.name, foreign_key: subject,
                                               dependent: :delete_all
      end
    end
  end
end
