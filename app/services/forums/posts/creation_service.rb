module Forums
  module Posts
    module CreationService
      include BaseService

      def call(user, thread, params)
        params = params.merge(created_by: user, thread: thread)
        post = Post.new(params)

        post.transaction do
          post.save || rollback!

          users = thread.subscriptions.where.not(user: user).map(&:user)
          notify_users(users, thread, post)
        end

        post
      end

      private

      def notify_users(users, thread, post)
        message = "#{post.created_by.name} posted on #{thread.title}"
        url = forums_thread_path(thread, anchor: "post_#{post.id}")

        users.each do |user|
          user.notify!(message, url)
        end
      end
    end
  end
end
