class AddAdminNotesToRostersTeamsAndUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :notice, :text, null: false, default: ''
    add_column :users, :notice_render_cache, :text, null: false, default: ''

    add_column :teams, :notice, :text, null: false, default: ''
    add_column :teams, :notice_render_cache, :text, null: false, default: ''

    add_column :league_rosters, :notice, :text, null: false, default: ''
    add_column :league_rosters, :notice_render_cache, :text, null: false, default: ''
  end
end
