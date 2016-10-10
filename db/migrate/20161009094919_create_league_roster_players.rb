class CreateLeagueRosterPlayers < ActiveRecord::Migration[5.0]
  def change
    create_table :league_roster_players do |t|
      t.belongs_to :user,   index: true, foreign_key: true
      t.belongs_to :roster, index: true

      t.timestamps null: false
    end

    add_foreign_key :league_roster_players, :league_rosters, column: :roster_id

    reversible do |dir|
      dir.up do
        create_players_from_transfers
      end
    end
  end

  private

  def create_players_from_transfers
    League::Roster.find_each do |roster|
      tfers = roster.transfers.select("DISTINCT ON(user_id) id")
                              .where(approved: true)
                              .reorder(:user_id, created_at: :desc)

      roster.transfers.where(id: tfers, is_joining: true)
                      .joins(:user)
                      .reorder('users.name')
                      .includes(:user)
                      .each do |transfer|
                        # Avoid all rails interaction to avoid callbacks, which create data
                        table = League::Roster::Player.table_name
                        execute "INSERT INTO #{table} (user_id, roster_id, created_at, updated_at)
                                 VALUES (#{transfer.user.id}, #{transfer.roster.id},
                                         #{ActiveRecord::Base.connection.quote(transfer.created_at)},
                                         #{ActiveRecord::Base.connection.quote(transfer.updated_at)})"
                      end
    end
  end
end
