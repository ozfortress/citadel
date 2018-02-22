class User
  class Comment < ApplicationRecord
    include Paths
    include MarkdownRenderCaching
    include Users::DeletedBy

    belongs_to :created_by, class_name: 'User'
    belongs_to :user

    has_many :edits, class_name: 'CommentEdit', dependent: :delete_all

    validates :content, presence: true
    caches_markdown_render_for :content

    scope :ordered, -> { order(:created_at) }

    def create_edit!(user)
      CommentEdit.create!(created_by: user, comment: self, content: content,
                          content_render_cache: content_render_cache)
    end

    paths do
      def show
        user_path(user_id, anchor: dom_id)
      end

      def destroy
        user_comment_path(user_id, id)
      end

      alias_method :update, :destroy

      def edit
        edit_user_comment_path(user_id, id)
      end

      def edits
        edits_for_user_comment_path(user_id, id)
      end

      def restore
        restore_user_comment_path(user_id, id)
      end
    end
  end
end
