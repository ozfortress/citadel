class CreateLeagueSchedulersWeeklies < ActiveRecord::Migration[5.0]
  def change
    create_table :league_schedulers_weeklies do |t|
      t.belongs_to :league, index: true, foreign_key: true, null: false

      t.integer :start_of_week, null: false
      t.boolean :days, array: 7, default: Array.new(7, true), null:false
      t.integer :minimum_selected, default: 0, null: false
    end
  end
end
