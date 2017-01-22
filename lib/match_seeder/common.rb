module MatchSeeder
  module Common
    extend self

    class Rollback < RuntimeError
      attr_reader :match

      def initialize(match)
        @match = match
      end
    end

    def get_roster_pool(target)
      target.rosters.approved.order(:seeding, :created_at)
    end

    def create_match_for(home_team, away_team, options)
      if home_team && away_team && home_away_difference(home_team) > home_away_difference(away_team)
        home_team, away_team = away_team, home_team
      end

      match_options = get_opts(home_team, away_team, options)

      match = League::Match.create(match_options)
      raise(Rollback, match) unless match.persisted?
      match
    end

    # Dirty hack for making a transaction always have a result, even if invalid
    def transaction
      result = nil

      ActiveRecord::Base.transaction do
        begin
          result = yield

        rescue Rollback => error
          result = [error.match]

          raise ActiveRecord::Rollback
        end
      end

      result
    end

    private

    def home_away_difference(team)
      team.home_team_matches.not_bye.size - team.away_team_matches.size
    end

    def get_opts(home_team, away_team, options)
      match_options = options.merge(home_team: home_team, away_team: away_team)

      match_options[:rounds] = match_options[:rounds].map(&:dup) if match_options.key? :rounds

      match_options
    end
  end
end
