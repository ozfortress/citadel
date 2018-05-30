class RemovePermissionsForCaptainsNotInTeams < ActiveRecord::Migration[5.1]
  def change
    reversible do |dir|
      dir.up do
        Team.find_each do |team|
          User.which_can(:edit, team).find_each do |user|
            user.revoke(:edit, team) unless team.users.include?(user)
          end
        end
      end
    end
  end
end
