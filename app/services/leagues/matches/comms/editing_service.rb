module Leagues
  module Matches
    module Comms
      module EditingService
        include BaseService

        def call(user, comm, params)
          edit_params = params.merge(user: user)

          comm.transaction do
            comm.update(params) || rollback!

            comm.edits.create!(edit_params)
          end

          comm
        end
      end
    end
  end
end
