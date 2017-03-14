module Leagues
  module Matches
    module GenerationService
      include BaseService

      def call(division, match_params, tournament_system, tournament_options)
        invalid_match = nil

        division.transaction do
          matches = division.generate_matches(tournament_system, match_params, tournament_options)
          invalid_match = matches.find { |match| !match.save }
          rollback! if invalid_match

          matches.each do |mat|
            CreationService.notify_for_match!(mat)
          end
        end

        invalid_match
      end
    end
  end
end
