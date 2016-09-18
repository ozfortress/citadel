module Forums
  module Threads
    module CreationService
      include BaseService

      def call(user, topic, params, post_params)
        params = params.merge(created_by: user, topic: topic)
        thread = Thread.new(params)

        post_params[:created_by] = user
        thread.posts.new(post_params)

        save_thread(user, topic, thread)

        thread
      end

      private

      def save_thread(user, topic, thread)
        thread.transaction do
          thread.save || rollback!
          user.forums_subscriptions.create!(thread: thread)

          if topic
            users = topic.subscriptions.where.not(user: user).map(&:user)
            notify_users(users, topic, thread)
          end
        end
      end

      def notify_users(users, topic, thread)
        message = "#{thread.created_by.name} created #{thread.title} in #{topic.name}"
        url = forums_thread_path(thread)

        users.each do |user|
          user.notify!(message, url)
        end
      end
    end
  end
end
