module Auth
  module MigrationHelper
    def add_action_auth(actor, action, subject)
      name = Auth.auth_name(actor, action, subject)

      subject_singular = subject.to_s.singularize == subject.to_s

      create_table name do |t|
        t.belongs_to actor,   index: true, foreign_key: true
        t.belongs_to subject, index: true, foreign_key: true if subject_singular
      end
    end

    def remove_action_auth(actor, action, subject)
      drop_table Auth.auth_name(actor, action, subject)
    end
  end
end
