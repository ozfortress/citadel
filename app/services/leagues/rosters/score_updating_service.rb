module Leagues
  module Rosters
    module ScoreUpdatingService
      # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      include BaseService

      SCORE_ATTRIBUTES = [
        :id, :ranking, :placement, :seeding, :disbanded, :points,
        :total_scores, :total_score_difference, :won_rounds_count, :drawn_rounds_count, :lost_rounds_count,
        :won_matches_count, :drawn_matches_count, :lost_matches_count, :bye_matches_count, :forfeit_won_matches_count,
        :forfeit_drawn_matches_count, :forfeit_lost_matches_count, :normalized_round_score, :buchholz_score,
        :median_buchholz_score
      ].freeze

      def call_each_division(league)
        league.divisions.find_each do |division|
          call(league, division)
        end
      end

      def call(league, division)
        rosters = division.rosters.select(*SCORE_ATTRIBUTES).to_a
        roster_id_map = rosters.map { |roster| [roster.id, roster] }.to_h

        # Gather stats for later calculations
        roster_results = Hash.new { |h, k| h[k] = [] }
        opponents_map = Hash.new { |h, k| h[k] = Hash.new { |h1, k1| h1[k1] = [] } }

        division.matches.confirmed.find_each do |match|
          home = roster_id_map[match.home_team_id]

          if match.bye?
            roster_results[home].push MatchStats.new(:win, 0, 0, 0, 0, 0, true)
            next
          end

          away = roster_id_map[match.away_team_id]
          home_stats, away_stats = build_match_stats(match)
          roster_results[home].push home_stats
          roster_results[away].push away_stats
          opponents_map[home][away].push OpponentEncounter.new(home, home_stats)
          opponents_map[away][home].push OpponentEncounter.new(away, away_stats)
        end

        update_rosters(league, rosters, roster_results, opponents_map)
      end

      private

      OpponentEncounter = Struct.new(:opponent, :stats)

      MatchStats = Struct.new(:result, :score, :score_difference, :round_wins, :round_losses, :round_draws, :bye)

      def build_match_stats(match)
        if match.no_forfeit?
          results = match_results(match)

          [MatchStats.new(results[0], match.total_home_team_score, match.total_score_difference,
                          match.total_home_team_round_wins, match.total_away_team_round_wins, match.total_round_draws,
                          false),
           MatchStats.new(results[1], match.total_away_team_score, -match.total_score_difference,
                          match.total_away_team_round_wins, match.total_home_team_round_wins, match.total_round_draws,
                          false)]
        else
          match_ff_results(match).map { |result| MatchStats.new(result, 0, 0, 0, 0, 0, false) }
        end
      end

      def match_results(match)
        if match.has_winner?
          if match.winner_id == match.home_team_id
            [:win, :loss]
          else
            [:loss, :win]
          end
        else
          [:draw, :draw]
        end
      end

      def match_ff_results(match)
        if match.home_team_forfeit?
          [:ff_loss, :ff_win]
        elsif match.away_team_forfeit?
          [:ff_win, :ff_loss]
        elsif match.mutual_forfeit?
          [:ff_loss, :ff_loss]
        elsif match.technical_forfeit?
          [:ff_draw, :ff_draw]
        else
          raise 'Internal Error'
        end
      end

      def update_rosters(league, rosters, roster_results, opponents_map)
        points_map = Hash.new { |h, k| h[k] = [] }

        # Update scores from gathered stats
        rosters.each do |roster|
          stats = roster_results[roster]

          roster.assign_attributes(
            total_scores: stats.sum(&:score),
            total_score_difference: stats.sum(&:score_difference),
            won_rounds_count: stats.sum(&:round_wins),
            drawn_rounds_count: stats.sum(&:round_draws),
            lost_rounds_count: stats.sum(&:round_losses),
            won_matches_count: stats.count { |s| s.result == :win },
            drawn_matches_count: stats.count { |s| s.result == :draw },
            lost_matches_count: stats.count { |s| s.result == :loss },
            bye_matches_count: stats.count(&:bye),
            forfeit_won_matches_count: stats.count { |s| s.result == :ff_win },
            forfeit_drawn_matches_count: stats.count { |s| s.result == :ff_draw },
            forfeit_lost_matches_count: stats.count { |s| s.result == :ff_loss }
          )
          roster.points = calculate_points(league, roster)
          points_map[roster.points].push roster
          roster.normalized_round_score = roster.won_rounds_count * 1.0 + roster.drawn_rounds_count * 0.5
        end

        # Update scores based on opponents
        rosters.each do |roster|
          opponents = opponents_map[roster]
          opponent_rosters = opponents.keys
          tied_encounters = points_map[roster.points].map { |r| opponents[r] }.reduce(:concat)

          roster.won_rounds_against_tied_rosters_count = tied_encounters.sum { |encounter| encounter.stats.round_wins }
          roster.buchholz_score = opponent_rosters.sum(&:normalized_round_score) * roster.normalized_round_score
          roster.median_buchholz_score = median_sum(opponent_rosters.map(&:normalized_round_score)) *
                                         roster.normalized_round_score
        end

        # Perform ranking and save
        ranked = rosters.sort_by { |roster| roster.order_keys_for(league) }

        ActiveRecord::Base.transaction do
          ranked.each_with_index do |roster, index|
            roster.placement = index
            roster.save!(validate: false)
          end
        end
      end

      def calculate_points(league, roster)
        return 0 if roster.disbanded?

        counters = [:won_rounds_count,          :drawn_rounds_count,          :lost_rounds_count,
                    :won_matches_count,         :drawn_matches_count,         :lost_matches_count,
                    :forfeit_won_matches_count, :forfeit_drawn_matches_count, :forfeit_lost_matches_count]

        counters.map { |f| roster.send(f) }.zip(league.point_multipliers).map { |x, y| x * y }.sum
      end

      def median_sum(scores)
        return 0 if scores.length < 3

        scores.sum - scores.min - scores.max
      end
      # rubocop:enable Metrics/AbcSize, Metrics/MethodLength
    end
  end
end
