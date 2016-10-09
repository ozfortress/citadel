class CreateTeamPlayers < ActiveRecord::Migration[5.0]
  def change
    create_table :team_players do |t|
      t.belongs_to :user, index: true, foreign_key: true
      t.belongs_to :team, index: true, foreign_key: true

      t.timestamps
    end

    reversible do |dir|
      dir.up do
        create_players_from_transfers
      end
    end
  end

  private

  def create_players_from_transfers
    Team.find_each do |team|
      tfers = team.transfers.select("DISTINCT ON(user_id) id")
                            .reorder(:user_id, created_at: :desc)

      team.transfers.where(id: tfers, is_joining: true)
                    .joins(:user)
                    .reorder('users.name')
                    .includes(:user)
                    .each do |transfer|
                      team.players.create!(user: transfer.user)
                    end
    end
  end
end
