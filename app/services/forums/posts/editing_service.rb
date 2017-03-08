module Forums
  module Posts
    module EditingService
      include BaseService

      def call(user, post, params)
        post.transaction do
          post.update(params) || rollback!

          post.create_edit!(user)
        end

        post
      end
    end
  end
end
