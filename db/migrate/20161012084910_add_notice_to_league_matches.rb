class AddNoticeToLeagueMatches < ActiveRecord::Migration[5.0]
  def change
    add_column :league_matches, :notice, :string, null: false, default: ''
  end
end
