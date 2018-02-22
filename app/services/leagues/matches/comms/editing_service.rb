module Leagues
  module Matches
    module Comms
      module EditingService
        include BaseService

        def call(creator, comm, params)
          comm.transaction do
            comm.update(params) || rollback!

            comm.create_edit!(creator)
          end

          comm
        end
      end
    end
  end
end
