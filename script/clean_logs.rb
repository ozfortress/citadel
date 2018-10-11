BACKLOG = 1.month

VISIT_EXACT_COLUMNS = [:ip, :user_agent, :browser, :os].freeze
VISIT_DISTINCT_COLUMNS = [:user_id, :api_key_id].freeze

keep_time = Time.zone.now - BACKLOG

Visit.transaction do
  # Delete all events beyond the backlog
  deleted = Ahoy::Event.where('time < ?', keep_time).delete_all
  puts "Deleted #{deleted} event records"

  # De-duplicate visits beyond the backlog
  conditions = VISIT_EXACT_COLUMNS.map { |name| "visits.#{name} = t2.#{name}" }
  op = 'IS NOT DISTINCT FROM'
  conditions += VISIT_DISTINCT_COLUMNS.map { |name| "visits.#{name} #{op} t2.#{name}" }
  condition = conditions.join(' AND ')

  deleted = Visit.connection.execute(<<-SQL).cmd_tuples
    DELETE FROM visits
    WHERE started_at < #{ActiveRecord::Base.sanitize(keep_time)} AND EXISTS(
      SELECT 1 FROM visits AS t2
      WHERE #{condition} AND t2.id > visits.id
  SQL

  puts "Deleted #{deleted} duplicate visit records"

  raise ActiveRecord::Rollback
end
