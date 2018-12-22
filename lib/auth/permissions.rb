module Auth
  # :reek:DataClump
  class Permissions
    def initialize(instances)
      @instances = instances.is_a?(Enumerable) ? instances : [instances]
      @model = @instances.first.class
    end

    def fetch(action, subject)
      fetch_grants(action, subject)
      fetch_active_bans(action, subject)
    end

    def fetch_grants(action, subject)
      grant = @model.grant_model_for(action, subject)
      return unless grant

      clear_instance_cache(:grants, action, subject)
      ids = get_actions_relation(grant, subject).pluck(actor_id)
      set_instance_cache(:grants, action, subject, ids)
    end

    def fetch_active_bans(action, subject)
      ban = @model.ban_model_for(action, subject)
      return unless ban

      clear_instance_cache(:active_bans, action, subject)
      ids = get_actions_relation(ban, subject).active.pluck(actor_id)
      set_instance_cache(:active_bans, action, subject, ids)
    end

    # rubocop:disable Style/AccessModifierDeclarations
    private(*delegate(:actor_name, :actor_id, to: :model))
    # rubocop:enable Style/AccessModifierDeclarations

    private

    attr_reader :model

    def clear_instance_cache(attribute, action, subject)
      @instances.each do |instance|
        instance.send(attribute)[action][subject] = false
      end
    end

    # :reek:LongParameterList
    def set_instance_cache(attribute, action, subject, ids)
      ids.each do |id|
        instance_map[id].send(attribute)[action][subject] = true
      end
    end

    def instance_map
      @instance_map ||= @instances.index_by(&:id)
    end

    def get_actions_relation(action_model, subject)
      action_model.where(actor_name => @instances).for(subject)
    end
  end
end
