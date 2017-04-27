class AddCounterCachesToForums < ActiveRecord::Migration[5.0]
  def change
    add_column :league_match_comms, :edits_count, :integer, null: false, default: 0

    reversible do |dir|
      dir.up do
        League::Match::Comm.select(:id).find_each do |comm|
          League::Match::Comm.reset_counters(comm.id, :edits)
        end
      end
    end
  end
end
