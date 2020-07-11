class League
  class Match
    class RoundPresenter < BasePresenter
      presents :round

      delegate :match, to: :round
      delegate :has_outcome?, to: :round

      def home_team
        present(match.home_team)
      end

      def away_team
        present(match.away_team)
      end

      def map
        present(round.map)
      end

      def result_description
        home = home_team.link
        away = away_team.link

        if match.no_forfeit?
          non_forfeit_results(home, away)
        else
          forfeit_results(home, away)
        end
      end

      def score_s
        "#{round.home_team_score} : #{round.away_team_score}"
      end

      def result(roster = nil)
        return if match.has_winner? && round.draw?

        if roster.nil?
          highlight_winner
        else
          roster_won_round?(roster)
        end
      end

      private

      def highlight_winner
        home_score = round.home_team_score
        away_score = round.away_team_score
        home_div = content_tag(:div, home_score, class: "score #{home_score > away_score ? 'won' : ''}")
        away_div = content_tag(:div, away_score, class: "score #{home_score < away_score ? 'won' : ''}")
        sep_div = content_tag(:div, ':', class: 'separator')
        content_tag(:div, home_div + sep_div + away_div, class: 'round')
      end

      def roster_won_round?(roster)
        winner_id = round.winner_id
        klass = if winner_id.nil?
                  'tied'
                elsif winner_id == roster.id
                  'won'
                else
                  'loss'
                end
        content_tag(:div, score_s, class: "roster-round #{klass}")
      end

      def non_forfeit_results(home, away)
        if round.home_team_score > round.away_team_score
          safe_join([home, 'beat', away], ' ')
        elsif round.home_team_score < round.away_team_score
          safe_join([home, 'lost to', away], ' ')
        else
          safe_join([home, 'tied with', away], ' ')
        end + ", #{round.home_team_score} to #{round.away_team_score}"
      end

      def forfeit_results(home, away)
        if match.home_team_forfeit?
          safe_join([away, 'wins by forfeit'], ' ')
        elsif match.away_team_forfeit?
          safe_join([home, 'wins by forfeit'], ' ')
        elsif match.mutual_forfeit?
          'mutual forfeit (both lose)'
        else
          'technical forfeit (both win)'
        end
      end
    end
  end
end
