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

      def results(roster = nil)
        if roster.nil?
          non_roster_result
        else
          roster_result(roster)
        end
      end

      private

      def non_roster_result
        if match.no_forfeit?
          highlight_winner
        else
          highlight_forfeit
        end
      end

      def roster_result(roster)
        if match.no_forfeit?
          roster_won_round?(roster)
        else
          roster_won_forfeit?(roster)
        end
      end

      def highlight_winner
        home_score = round.home_team_score
        away_score = round.away_team_score
        home_div = content_tag(:div, home_score,
                               class: ('score-highlight' if home_score > away_score))
        away_div = content_tag(:div, away_score,
                               class: ('score-highlight' if home_score < away_score))
        content_tag(:div, home_div + ' : ' + away_div, class: 'round-scores')
      end

      def roster_won_round?(roster)
        klass = if round.winner.nil?
                  'round-scores round-tied'
                elsif round.winner == roster
                  'round-scores round-won'
                else
                  'round-scores round-loss'
                end
        html_div("#{round.home_team_score} : #{round.away_team_score}", klass)
      end

      def highlight_forfeit
        if match.home_team_forfeit?
          html_div('home forfeited')
        elsif match.away_team_forfeit?
          html_div('away forfeited')
        elsif match.mutual_forfeit?
          html_div('mutual forfeit')
        else
          html_div('technical forfeit')
        end
      end

      def roster_won_forfeit?(roster)
        if round.forfeit_winner == 'none'
          html_div('mutual forfeit', 'round-scores round-loss')
        elsif round.forfeit_winner == 'both'
          html_div('technical forfeit', 'round-scores round-won')
        elsif round.forfeit_winner == roster
          html_div('forfeit won', 'round-scores round-won')
        else
          html_div('forfeit loss', 'round-scores round-loss')
        end
      end

      def html_div(text, style = nil)
        content_tag(:div, text, class: style)
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
