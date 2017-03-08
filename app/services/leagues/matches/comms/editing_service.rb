module Leagues
  module Matches
    module Comms
      module EditingService
        include BaseService

        def call(user, comm, params)
          comm.transaction do
            comm.update(params) || rollback!

            comm.create_edit!(user)
          end

          comm
        end
      end
    end
  end
end
