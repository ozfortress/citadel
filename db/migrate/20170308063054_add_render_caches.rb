class AddRenderCaches < ActiveRecord::Migration[5.0]
  def change
    add_column :users,          :description_render_cache, :text, null: false, default: ''
    add_column :teams,          :description_render_cache, :text, null: false, default: ''
    add_column :maps,           :description_render_cache, :text, null: false, default: ''
    add_column :leagues,        :description_render_cache, :text, null: false, default: ''
    add_column :formats,        :description_render_cache, :text, null: false, default: ''
    add_column :league_rosters, :description_render_cache, :text, null: false, default: ''

    add_column :league_roster_comments,  :content_render_cache, :text, null: false, default: ''
    add_column :league_matches,          :notice_render_cache,  :text, null: false, default: ''
    add_column :league_match_comms,      :content_render_cache, :text, null: false, default: ''
    add_column :league_match_comm_edits, :content_render_cache, :text, null: false, default: ''

    add_column :forums_posts,      :content_render_cache, :text, null: false, default: ''
    add_column :forums_post_edits, :content_render_cache, :text, null: false, default: ''

    reversible do |dir|
      dir.up do
        [
          User, Team, Map, League, Format,
          League::Roster, League::Roster::Comment,
          League::Match, League::Match::Comm,
          Forums::Post,
        ].each do |cls|
          cls.find_each { |object| object.reset_render_caches! }
        end

        League::Match::CommEdit.find_each do |edit|
          edit.update!(content_render_cache: MarkdownRenderer.render(edit.content))
        end

        Forums::PostEdit.find_each do |edit|
          edit.update!(content_render_cache: MarkdownRenderer.render(edit.content))
        end
      end
    end
  end
end
