module Auth
  module MigrationHelper
    def add_action_auth(actor, action, subject)
      name = Auth::Util.grant_name(actor, action, subject)

      subject_s = subject.to_s
      singular = subject_s.singularize == subject_s

      create_table name do |t|
        t.belongs_to actor,   index: true, foreign_key: true
        t.belongs_to subject, index: true, foreign_key: true if singular
      end
    end

    def remove_action_auth(actor, action, subject)
      drop_table Auth::Util.grant_name(actor, action, subject)
    end

    def add_action_ban(actor, action, subject)
      name = Auth::Util.ban_name(actor, action, subject)

      subject_s = subject.to_s
      singular = subject_s.singularize == subject_s

      create_table name do |t|
        t.belongs_to actor,   index: true, foreign_key: true
        t.belongs_to subject, index: true, foreign_key: true if singular

        t.string   :reason,        null: false, default: ''
        t.datetime :terminated_at, null: true

        t.timestamps null: false
      end
    end

    def remove_action_ban(actor, action, subject)
      drop_table Auth::Util.ban_name(actor, action, subject)
    end
  end
end
