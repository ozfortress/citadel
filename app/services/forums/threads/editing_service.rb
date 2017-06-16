module Forums
  module Threads
    module EditingService
      include BaseService

      def call(user, thread, params, post, post_params)
        thread.transaction do
          thread.assign_attributes(params)
          thread.save || rollback!

          Posts::EditingService.call(user, post, post_params)
          rollback! if post.changed?

          thread
        end
      end
    end
  end
end
