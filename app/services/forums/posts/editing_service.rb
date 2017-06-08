module Forums
  module Posts
    module EditingService
      include BaseService

      def call(user, post, params)
        post.transaction do
          post.assign_attributes(params)
          return post unless post.changed?

          post.save || rollback!

          post.create_edit!(user)
        end

        post
      end
    end
  end
end
