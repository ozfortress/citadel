module Leagues
  module Rosters
    module Comments
      module CreationService
        include BaseService

        def call(creator, roster, params)
          comment_params = params.merge(roster: roster, created_by: creator)
          comment = League::Roster::Comment.new(comment_params)

          comment.transaction do
            comment.save || rollback!

            comment.create_edit!(creator)
          end

          comment
        end
      end
    end
  end
end
