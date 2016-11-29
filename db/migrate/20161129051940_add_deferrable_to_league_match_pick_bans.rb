class AddDeferrableToLeagueMatchPickBans < ActiveRecord::Migration[5.0]
  def change
    add_column :league_match_pick_bans, :deferrable, :boolean, default: false, null: false
  end
end
