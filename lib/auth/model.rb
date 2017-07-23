require 'auth/grant'
require 'auth/ban'
require 'auth/util'
require 'auth/permissions'

module Auth
  module Model
    extend ActiveSupport::Concern

    # Override reload to reset the permission cache
    def reload
      @permissions = nil
      @grants = nil
      @active_bans = nil
      super
    end

    # Mutation
    def grant(action, subject, options = {})
      grants_for(action, subject).create!(options)
      grants[action][subject] = true
    end

    def revoke(action, subject)
      grants_for(action, subject).delete_all
      grants[action][subject] = false
    end

    def ban(action, subject, options = {})
      ban = bans_for(action, subject).create!(options)
      active_bans[action][subject] = ban.active?
    end

    def unban_all(action, subject)
      bans_for(action, subject).delete_all
      active_bans[action][subject] = false
    end

    # Querying
    def permissions
      @permissions ||= Permissions.new(self)
    end

    def grants
      @grants ||= Hash.new { |hash, key| hash[key] = {} }
    end

    def active_bans
      @active_bans ||= Hash.new { |hash, key| hash[key] = {} }
    end

    def can?(action, subject)
      granted?(action, subject) && !actively_banned?(action, subject)
    end

    def can_for(action, subject)
      grant = self.class.grant_model_for(action, subject)

      send(grant.association_name).includes(subject).references(subject).map(&subject)
    end

    # :reek:DuplicateMethodCall :reek:FeatureEnvy
    def granted?(action, subject)
      subjects = grants[action]
      permissions.fetch_grants(action, subject) unless subjects.key?(subject)
      if subjects.key?(subject)
        subjects[subject]
      else
        true
      end
    end

    # :reek:DuplicateMethodCall :reek:FeatureEnvy
    def actively_banned?(action, subject)
      subjects = active_bans[action]
      permissions.fetch_active_bans(action, subject) unless subjects.key?(subject)
      if subjects.key?(subject)
        subjects[subject]
      else
        false
      end
    end

    def grants_for(action, subject)
      grant = self.class.grant_model_for(action, subject)
      return [nil] unless grant
      send(grant.association_name).for(subject)
    end

    def bans_for(action, subject)
      ban = self.class.ban_model_for(action, subject)
      return Ban.none unless ban
      send(ban.association_name).for(subject)
    end

    class_methods do
      def actor_name
        name.underscore.to_sym
      end

      def actor_id
        "#{name.underscore}_id".to_sym
      end

      def permissions(collection = nil)
        Permissions.new(collection || all)
      end

      def grant_models
        @grant_models ||= Hash.new { |hash, key| hash[key] = {} }
      end

      def ban_models
        @ban_models ||= Hash.new { |hash, key| hash[key] = {} }
      end

      def validates_permission_to(action, subject, options = {})
        table_name = Util.grant_name(actor_name, action, subject)

        grant = create_model(Auth::Grant, table_name: table_name, actor: self, action: action,
                                          subject: subject, subject_options: options)

        grant_models[action].update(subject => grant)
      end

      def validates_prohibition_to(action, subject, options = {})
        table_name = Util.ban_name(actor_name, action, subject)

        ban = create_model(Auth::Ban, table_name: table_name, actor: self, action: action,
                                      subject: subject, subject_options: options)

        ban_models[action].update(subject => ban)
      end

      def grant_model_for(action, subject)
        subject_name = Util.get_subject_name(subject)

        grant_models[action][subject_name]
      end

      def ban_model_for(action, subject)
        subject_name = Util.get_subject_name(subject)

        ban_models[action][subject_name]
      end

      def which_can(action, subject)
        grant = grant_model_for(action, subject)
        association_name = grant.association_name
        result = joins(association_name)

        if grant.subject? && !subject.is_a?(Symbol)
          subject_name = Util.get_subject_name(subject)
          result = result.where(association_name => { subject_name => subject })
        end

        result
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
