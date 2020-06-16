module Forums
  module Permissions
    extend ActiveSupport::Concern

    def user_can_manage_forums?
      user_signed_in? && current_user.can?(:manage, :forums)
    end

    def user_can_manage_topic?(topic = nil)
      topic ||= @topic

      return user_can_manage_forums? unless topic

      user_signed_in? && (topic.not_isolated? && user_can_manage_forums? ||
                          user_can_manage_topics?(topic.ancestors) ||
                          current_user.can?(:manage, topic))
    end

    def user_can_view_topic?(topic = nil)
      topic ||= @topic

      user_can_manage_topic?(topic) || !topic.hidden?
    end

    def user_can_use_topic?(topic = nil)
      topic ||= @topic

      user_signed_in? && current_user.can?(:use, :forums) &&
        current_user.can?(:use, topic) && user_can_use_topics?(topic.ancestors)
    end

    def user_can_create_thread?(topic = nil)
      topic ||= @topic

      user_can_manage_topic?(topic) ||
        (user_signed_in? && topic && user_can_use_topic?(topic) && !topic.locked? && !topic.hidden?)
    end

    def user_can_manage_thread?(thread = nil)
      thread ||= @thread

      return user_can_manage_forums? unless thread

      user_signed_in? && (thread.not_isolated? && user_can_manage_forums? ||
                          user_can_manage_topics?(thread.ancestors) ||
                          current_user.can?(:manage, thread))
    end

    def user_can_edit_thread?(thread = nil)
      thread ||= @thread

      user_can_manage_thread?(thread) ||
        (user_signed_in? && current_user == thread.created_by &&
         !thread.locked? && user_can_use_thread?(thread))
    end

    def user_can_view_thread?(thread = nil)
      thread ||= @thread

      user_can_edit_thread?(thread) || !thread.hidden
    end

    def user_can_use_thread?(thread = nil)
      thread ||= @thread

      user_signed_in? && current_user.can?(:use, thread) && (thread.topic.nil? || user_can_use_topic?(thread.topic))
    end

    def user_can_create_post?(thread = nil)
      thread ||= @thread

      user_can_edit_thread?(thread) ||
        (user_signed_in? && !thread.locked? && user_can_use_thread?(thread) &&
         (!thread.hidden? || thread.created_by == current_user))
    end

    def user_can_edit_post?(post = nil)
      post ||= @post

      user_can_manage_thread?(post.thread) ||
        (user_signed_in? && post.created_by == current_user && user_can_use_thread?(post.thread))
    end

    private

    def user_can_manage_topics?(topics)
      return false if topics.empty?

      isolation_depth = topics.isolated.maximum(:ancestry_depth) || 0

      current_user.can?(:manage, topics.from_depth(isolation_depth))
    end

    def user_can_use_topics?(topics)
      return true if topics.empty?

      isolation_depth = topics.isolated.maximum(:ancestry_depth) || 0

      current_user.can?(:use, topics.from_depth(isolation_depth))
    end
  end
end
