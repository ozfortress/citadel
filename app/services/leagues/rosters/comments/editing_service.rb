module Leagues
  module Rosters
    module Comments
      module EditingService
        include BaseService

        def call(user, comment, params)
          comment.transaction do
            comment.update(params) || rollback!

            comment.create_edit!(user)
          end

          comment
        end
      end
    end
  end
end
