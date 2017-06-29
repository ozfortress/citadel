class AddCategoryToLeagues < ActiveRecord::Migration[5.0]
  def change
    add_column :leagues, :category, :string, null: false, default: '', index: true
  end
end
