class RemoveTeamDependencyOnFormats < ActiveRecord::Migration[4.2]
  def change
    remove_column :teams, :format_id
  end
end
