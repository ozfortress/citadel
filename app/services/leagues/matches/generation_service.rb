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

          create_notifications_for_matches(matches)
        rescue League::Division::GenerationError => e
          return invalid_match(match_params, e)
        end

        invalid_match
      end

      private

      def invalid_match(params, error)
        match = League::Match.new(params)
        match.valid? && raise
        match.errors.add(:base, error.message)
        match
      end

      def create_notifications_for_matches(matches)
        matches.each do |match|
          CreationService.notify_for_match!(match)
        end
      end
    end
  end
end
