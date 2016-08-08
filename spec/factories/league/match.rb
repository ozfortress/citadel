FactoryGirl.define do
  factory :league_match, class: League::Match do
    status :pending
    round 1

    transient do
      division nil
    end

    after(:build) do |match, evaluator|
      div = if match.home_team || match.away_team
              (match.home_team || match.away_team).division
            else
              evaluator.division || create(:league_division)
            end
      match.home_team = create(:league_roster, division: div) unless match.home_team
      match.away_team = create(:league_roster, division: div) unless match.away_team
    end
  end

  factory :bye_match, class: League::Match do
    status :pending
    away_team nil
    round 1

    after(:build) do |match, _|
      div = if match.home_team
              match.home_team.division
            else
              create(:league_division)
            end
      match.home_team = create(:league_roster, division: div) unless match.home_team
    end
  end
end
