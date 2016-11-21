class CreateLeaguePooledMaps < ActiveRecord::Migration[5.0]
  def change
    create_table :league_pooled_maps do |t|
      t.belongs_to :league, index: true, foreign_key: true
      t.belongs_to :map, foreign_key: true

      t.timestamps null: false
    end
  end
end
