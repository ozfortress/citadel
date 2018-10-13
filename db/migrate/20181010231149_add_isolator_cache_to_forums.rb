class AddIsolatorCacheToForums < ActiveRecord::Migration[5.2]
  def change
    add_column :forums_topics, :isolated_by_id, :integer, null: true, index: true
    add_foreign_key :forums_topics, :forums_topics, column: :isolated_by_id

    reversible do |dir|
      dir.up do
        Forums::Topic.find_each do |topic|
          if topic.isolated?
            topic.update!(isolated_by: topic)
            next
          end

          topic.ancestors.find_each do |parent_topic|
            if parent_topic.isolated?
              topic.update!(isolated_by: parent_topic)
              break
            end
          end
        end
      end
    end
  end
end
