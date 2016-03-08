class RemoveDescriptionFromDivisions < ActiveRecord::Migration
  def change
    remove_column :divisions, :description, :text
  end
end
