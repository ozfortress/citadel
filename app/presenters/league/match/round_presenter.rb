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
            home_div = content_tag(:div, round.home_team_score, class: ("score-highlight" if round.home_team_score > round.away_team_score))
            away_div = content_tag(:div, round.away_team_score, class: ("score-highlight" if round.home_team_score < round.away_team_score))
            return content_tag(:div, home_div + " : " + away_div, class: "round-scores")
          else
            winner = check_winner(home_team, away_team, roster)

            if winner === ""
              color = "round-scores round-tied"
            elsif roster.name === winner.name
              color = "round-scores round-won"
            else
              color = "round-scores round-loss"
            end
            
            home_div = content_tag(:div, round.home_team_score)
            away_div = content_tag(:div, round.away_team_score)

            return content_tag(:div, home_div + " : " + away_div, class: color)
          end
        else
          if match.home_team_forfeit?
            return "home forfeit"
          elsif match.away_team_forfeit?
            return "away forfeit"
          elsif match.mutual_forfeit?
            return "mutual forfeit"
          else
            return "tech forfeit"
          end
        end
      end

      private

      def check_winner(home, away, roster)
        if round.home_team_score > round.away_team_score
          winner = home
        elsif round.home_team_score < round.away_team_score
          winner = away
        else
          winner = ""
        end 
        return winner
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