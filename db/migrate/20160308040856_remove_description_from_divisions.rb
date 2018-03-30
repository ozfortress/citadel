class RemoveDescriptionFromDivisions < ActiveRecord::Migration[4.2]
  def change
    remove_column :divisions, :description, :text
  end
end
