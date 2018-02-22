class AddEditsForComments < ActiveRecord::Migration[5.0]
  def change
    create_table :league_roster_comment_edits do |t|
      t.integer  :comment_id,    null: false, index: true
      t.integer  :created_by_id, null: false, index: true

      t.string :content, null: false
      t.text :content_render_cache, null: false, default: ''

      t.timestamps null: false
    end

    add_foreign_key :league_roster_comment_edits, :league_roster_comments, column: :comment_id
    add_foreign_key :league_roster_comment_edits, :users,                  column: :created_by_id

    create_table :user_comment_edits do |t|
      t.integer  :comment_id,    null: false, index: true
      t.integer  :created_by_id, null: false, index: true

      t.string :content, null: false
      t.text :content_render_cache, null: false, default: ''

      t.timestamps null: false
    end

    add_foreign_key :user_comment_edits, :user_comments, column: :comment_id
    add_foreign_key :user_comment_edits, :users,         column: :created_by_id

    reversible do |direction|
      direction.up do
        League::Roster::Comment.find_each do |comment|
          comment.create_edit!(comment.created_by)
        end

        User::Comment.find_each do |comment|
          comment.create_edit!(comment.created_by)
        end
      end
    end
  end
end
