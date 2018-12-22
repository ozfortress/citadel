class CreateUserLogs < ActiveRecord::Migration[5.2]
  def change
    create_table :user_logs do |t|
      t.belongs_to :user, null: false, foreign_key: true
      t.inet :ip, null: false
      t.datetime :first_seen_at, null: false
      t.datetime :last_seen_at, null: false
    end
    add_index :user_logs, [:user_id, :ip], unique: true
    add_index :user_logs, :ip

    reversible do |dir|
      dir.up do
        execute(<<-SQL)
          INSERT INTO user_logs (user_id, ip, first_seen_at, last_seen_at)
          SELECT DISTINCT ON (user_id, ip)
            user_id,
            ip::inet,
            COALESCE((SELECT MIN(started_at) FROM visits v2 WHERE v2.user_id = v.user_id AND v2.ip = v.ip), to_timestamp(0)) as fsa,
            COALESCE((SELECT MAX(started_at) FROM visits v2 WHERE v2.user_id = v.user_id AND v2.ip = v.ip), to_timestamp(0)) as lsa
          FROM visits v
          WHERE user_id IS NOT NULL
        SQL
      end
      dir.down do
        # This one is non-reversible, as information is lost
        fail ActiveRecord::IrreversibleMigration
      end
    end

    drop_table :visits
    drop_table :ahoy_events
  end
end
