class AddOrderNumberToLeagueMatchPickBans < ActiveRecord::Migration[5.1]
  def change
    add_column :league_match_pick_bans, :order_number, :integer, default: 0

    League::Match.find_each do |match|
      match.pick_bans.reorder(:created_at).each_with_index do |pick_ban, index|
        pick_ban.update!(order_number: index)
      end
    end
  end
end
