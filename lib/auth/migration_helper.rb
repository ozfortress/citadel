module Auth
  module MigrationHelper
    def add_action_auth(actor, action, subject)
      name = Auth.auth_name(actor, action, subject)

      subject_s = subject.to_s
      singular = subject_s.singularize == subject_s

      create_table name do |t|
        t.belongs_to actor,   index: true, foreign_key: true
        t.belongs_to subject, index: true, foreign_key: true if singular
      end
    end

    def remove_action_auth(actor, action, subject)
      drop_table Auth.auth_name(actor, action, subject)
    end
  end
end
