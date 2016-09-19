module Forums
  module Posts
    module EditingService
      include BaseService

      def call(user, post, params)
        edit_params = params.merge(post: post, created_by: user)

        post.transaction do
          post.update(params) || rollback!

          post.edits.create!(edit_params)
        end

        post
      end
    end
  end
end
