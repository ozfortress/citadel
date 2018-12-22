class User
  class Log < ApplicationRecord
    belongs_to :user

    def self.log_user!(user, ip)
      connection.exec_query(<<-SQL, 'log_user', [[nil, user.id], [nil, ip], [nil, Time.now.utc]])
          INSERT INTO user_logs (user_id, ip, first_seen_at, last_seen_at)
          VALUES ($1, $2::inet, $3, $3)
          ON CONFLICT (user_id, ip) DO UPDATE SET last_seen_at = $3
      SQL
    end
  end
end
