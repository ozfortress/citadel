module Forums
  module Posts
    module CreationService
      include BaseService

      def call(user, thread, params)
        params[:created_by] = user
        post_params = params.merge(thread: thread)
        post = Post.new(post_params)

        post.transaction do
          post.save || rollback!
          post.create_edit!(user)

          users = thread.subscriptions.where.not(user: user).map(&:user)
          notify_users(users, thread, post)
        end

        post
      end

      private

      def notify_users(users, thread, post)
        message = "#{post.created_by.name} posted on #{thread.title}"
        url = forums_thread_path(thread, page: Post.page_of(post), anchor: "post_#{post.id}")

        users.each do |user|
          Users::NotificationService.call(user, message, url)
        end
      end
    end
  end
end
