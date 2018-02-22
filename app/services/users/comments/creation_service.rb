module Users
  module Comments
    module CreationService
      include BaseService

      def call(creator, user, params)
        comment_params = params.merge(user: user, created_by: creator)
        comment = User::Comment.new(comment_params)

        comment.transaction do
          comment.save || rollback!

          comment.create_edit!(creator)
        end

        comment
      end
    end
  end
end
