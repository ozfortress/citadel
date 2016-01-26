require 'auth/string'

module AuthMigrationHelper
  def add_action_auth(actor, action, subject, options = {})
    states = options[:states] || 1

    name = auth_name(actor, action, subject)
    name = "#{name}_#{options[:group]}" if options[:group]

    subject_singular? = subject.singularize == subject

    create_table name do |t|
      t.belongs_to actor,   index: true, foreign_key: true
      t.belongs_to subject, index: true, foreign_key: true if subject_singular?
      t.integer    :state                                  if states > 1
    end
  end

  def remove_action_auth(actor, action, subject)
    drop_table auth_name(actor, action, subject)
  end

  private

  def auth_name(actor, action, subject)
    "#{actor}_#{action}_#{subject}"
  end
end
