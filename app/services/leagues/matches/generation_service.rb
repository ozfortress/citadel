module Leagues
  module Matches
    module GenerationService
      include BaseService

      def call(division, kind, match_params)
        match = nil

        division.transaction do
          matches = division.seed_round_with(kind, match_params)

          match = matches.first(&:invalid?)
          rollback! if match.invalid?

          matches.each do |mat|
            CreationService.notify_for_match!(mat)
          end
        end

        match
      end
    end
  end
end
