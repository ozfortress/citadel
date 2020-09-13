class AddPlacementsToLeagueRosters < ActiveRecord::Migration[5.2]
  def change
    add_column :league_rosters, :placement, :integer

    reversible do |dir|
      dir.up do
        League.find_each do |league|
          league.divisions.each do |division|
            Leagues::Rosters::ScoreUpdatingService.call(league, division)
          end
        end
      end
    end
  end
end
