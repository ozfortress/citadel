module Forums
  module Topics
    module IsolationService
      include BaseService

      def call(user, topic)
        topic.transaction do
          topic.update(isolated: true) || rollback!

          user.grant(:manage, topic) || rollback!

          topic
        end
      end
    end
  end
end
