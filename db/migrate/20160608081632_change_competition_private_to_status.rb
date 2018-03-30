class ChangeCompetitionPrivateToStatus < ActiveRecord::Migration[4.2]
  def up
    add_column :competitions, :status, :integer, null: false, default: 0

    Competition.find_each do |comp|
      comp.status = comp.private? ? 0 : 1
    end

    remove_column :competitions, :private
  end

  def down
    add_column :competitions, :private, :boolean, null: false

    Competition.find_each do |comp|
      comp.private = (comp.status == 0)
    end

    remove_column :status, :private
  end
end
