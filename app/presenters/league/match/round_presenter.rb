class League
  class Match
    class RoundPresenter < ActionPresenter::Base
      presents :round

      delegate :match, to: :round

      def home_team
        present(match.home_team)
      end

      def away_team
        present(match.away_team)
      end

      def result
        home = home_team.link
        away = away_team.link

        if match.no_forfeit?
          non_forfeit_results(home, away)
        else
          forfeit_results(home, away)
        end
      end

      def score(roster = nil)
        if match.no_forfeit?
          if roster.nil?
            highlight_winner
          else
            check_roster_won(roster)
          end
        else
          check_forfeit
        end
      end

      private

      def highlight_winner
        home_score = round.home_team_score
        away_score = round.away_team_score
        home_div = content_tag(:div, home_score,
                               class: ('score-highlight' if home_score > away_score))
        away_div = content_tag(:div, away_score,
                               class: ('score-highlight' if home_score < away_score))
        content_tag(:div, home_div + ' : ' + away_div, class: 'round-scores')
      end

      def check_roster_won(roster)
        klass = if round.winner.nil?
                  'round-scores round-tied'
                elsif round.winner == roster
                  'round-scores round-won'
                else
                  'round-scores round-loss'
                end
        winner_s(klass)
      end

      def winner_s(style)
        content_tag(:div, "#{round.home_team_score} : #{round.away_team_score}",
                    class: style)
      end

      def check_forfeit
        if match.home_team_forfeit?
          'home forfeit'
        elsif match.away_team_forfeit?
          'away forfeit'
        elsif match.mutual_forfeit?
          'mutual forfeit'
        else
          'tech forfeit'
        end
      end

      def non_forfeit_results(home, away)
        if round.home_team_score > round.away_team_score
          safe_join([home, 'beat', away], ' ')
        elsif round.home_team_score < round.away_team_score
          safe_join([home, 'lost to', away], ' ')
        else
          safe_join([home, 'tied with', away], ' ')
        end + ', #{round.home_team_score} to #{round.away_team_score}'
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
