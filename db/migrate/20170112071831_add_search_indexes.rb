class AddSearchIndexes < ActiveRecord::Migration[5.0]
  def change
    enable_extension :pg_trgm

    # add_index :teams, :name, using: 'gist(lower(unaccent(name)) gist_trgm_ops)',
    #                          name: 'index_users_on_name_gist'
    add_column :users, :query_name_cache, :string, default: "", null: false
    add_column :teams, :query_name_cache, :string, default: "", null: false
    add_column :leagues, :query_name_cache, :string, default: "", null: false

    users_index = 'index_users_on_query_name_cache'
    teams_index = 'index_teams_on_query_name_cache'
    leagues_index = 'index_leagues_on_query_name_change'

    reversible do |dir|
      dir.up do
        User.find_each { |user| user.reset_query_cache! }
        Team.find_each { |team| team.reset_query_cache! }
        League.find_each { |league| league.reset_query_cache! }

        execute("CREATE INDEX #{users_index} ON users USING gist(query_name_cache gist_trgm_ops)")
        execute("CREATE INDEX #{teams_index} ON teams USING gist(query_name_cache gist_trgm_ops)")
        execute("CREATE INDEX #{leagues_index} ON leagues USING gist(query_name_cache gist_trgm_ops)")
      end

      dir.down do
        execute("DROP INDEX #{users_index}")
        execute("DROP INDEX #{teams_index}")
        execute("DROP INDEX #{leagues_index}")
      end
    end
  end
end
