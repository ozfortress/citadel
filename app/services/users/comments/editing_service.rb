module Users
  module Comments
    module EditingService
      include BaseService

      def call(creator, user, params)
        user.transaction do
          user.update(params) || rollback!

          user.create_edit!(creator)
        end

        user
      end
    end
  end
end
