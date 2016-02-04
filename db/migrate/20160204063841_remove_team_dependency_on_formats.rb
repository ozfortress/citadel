class RemoveTeamDependencyOnFormats < ActiveRecord::Migration
  def change
    remove_column :teams, :format_id
  end
end
