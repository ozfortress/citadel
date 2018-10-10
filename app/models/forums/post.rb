module Forums
  class Post < ApplicationRecord
    include MarkdownRenderCaching

    default_scope { order(created_at: :asc) }

    belongs_to :thread, inverse_of: :posts, counter_cache: true
    belongs_to :created_by, class_name: 'User', inverse_of: :forums_posts, counter_cache: 'forums_posts_count'

    has_many :edits, class_name: 'PostEdit', inverse_of: :post, dependent: :delete_all

    validates :content, presence: true, length: { in: 10..10_000 }
    caches_markdown_render_for :content

    scope :publicly_viewable, -> { includes(:thread).where(forums_threads: { hidden: false }) }

    after_create do
      created_by.public_forums_posts_count += 1 if public?
      created_by.save!
    end

    def previous_post
      @previous_post ||= thread.posts.where('created_at < ?', created_at).last
    end

    def create_edit!(user)
      PostEdit.create!(created_by: user, post: self, content: content,
                       content_render_cache: content_render_cache)
    end

    def first_post?
      self == thread.posts.first
    end

    def public?
      !thread.hidden?
    end

    self.per_page = 8

    def self.page_of(post)
      return 1 unless post

      post_index = post.thread.posts.where('created_at < ?', post.created_at).count
      post_index / Post.per_page + 1
    end
  end
end
