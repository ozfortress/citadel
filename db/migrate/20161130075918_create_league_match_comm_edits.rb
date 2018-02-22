class CreateLeagueMatchCommEdits < ActiveRecord::Migration[5.0]
  def change
    create_table :league_match_comm_edits do |t|
      t.belongs_to :created_by, null: false, index: true, foreign_key: true
      t.integer :comm_id, null: false, index: true
      t.text :content,    null: false

      t.timestamps null: false
    end

    add_foreign_key :league_match_comm_edits, :league_match_comms, column: :comm_id

    reversible do |dir|
      dir.up do
        League::Match::Comm.find_each do |comm|
          comm.edits.create!(created_by: comm.created_by, content: comm.content)
        end
      end
    end
  end
end
