require 'auth/migration_helper'
require 'auth/grant'
require 'auth/ban'

module Auth
  module Model
    extend ActiveSupport::Concern

    included do
      scope :include_permission, (lambda do |action, subject|
        result = all
        grant = result.model.grant_model_for(action, subject)
        result = result.includes(grant.association_name) if grant
        ban = result.model.ban_model_for(action, subject)
        result = result.includes(ban.association_name) if ban
        result
      end)

      scope :include_permissions, (lambda do |*permissions|
        result = self
        permissions.each do |permission|
          result = result.include_permission(permission.first, permission.second)
        end
        result
      end)

      def klass
        self.class
      end

      def can?(action, subject)
        !grants_for(action, subject).empty? && !bans_for(action, subject).active.exists?
      end

      def can_for(action, subject)
        grant = klass.grant_model_for(action, subject)

        send(grant.association_name).includes(subject).references(subject).map(&subject)
      end

      def grant(action, subject, options = {})
        grants_for(action, subject).create!(options)
      end

      def revoke(action, subject)
        grants_for(action, subject).delete_all
      end

      def ban(action, subject, options = {})
        bans_for(action, subject).create!(options)
      end

      def unban(action, subject)
        bans_for(action, subject).delete_all
      end

      def grants_for(action, subject)
        grant = klass.grant_model_for(action, subject)
        return [nil] unless grant
        action_state_for(subject, grant)
      end

      def bans_for(action, subject)
        ban = klass.ban_model_for(action, subject)
        return Ban.none unless ban
        action_state_for(subject, ban)
      end

      private

      def action_state_for(subject, model)
        result = send(model.association_name)

        if model.subject? && !subject.is_a?(Symbol)
          subject_name = klass.get_subject_name(subject)
          result = result.where(subject_name => subject)
        end

        result
      end
    end

    class_methods do
      def actor_name
        name.underscore.to_sym
      end

      def grants
        @grants ||= Hash.new { |hash, key| hash[key] = {} }
      end

      def bans
        @bans ||= Hash.new { |hash, key| hash[key] = {} }
      end

      def validates_permission_to(action, subject, options = {})
        table_name = Auth.grant_name(actor_name, action, subject)

        grant = create_model(Auth::Grant, table_name: table_name, actor: self,
                                          subject: subject, subject_options: options)

        grants[action].update(subject => grant)
      end

      def validates_prohibition_to(action, subject, options = {})
        table_name = Auth.ban_name(actor_name, action, subject)

        ban = create_model(Auth::Ban, table_name: table_name, actor: self,
                                      subject: subject, subject_options: options)

        bans[action].update(subject => ban)
      end

      def grant_model_for(action, subject)
        subject_name = get_subject_name(subject)

        grants[action][subject_name]
      end

      def ban_model_for(action, subject)
        subject_name = get_subject_name(subject)

        bans[action][subject_name]
      end

      def which_can(action, subject)
        grant = grant_model_for(action, subject)
        association_name = grant.association_name
        result = joins(association_name)

        if grant.subject? && !subject.is_a?(Symbol)
          subject_name = get_subject_name(subject)
          result = result.where(association_name => { subject_name => subject })
        end

        result
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

      def create_model(type, options)
        model = Class.new(type)
        const_set(options[:table_name].camelize, model)

        model.init_model options
        model
      end
    end
  end
end
