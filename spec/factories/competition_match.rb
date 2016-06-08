FactoryGirl.define do
  factory :competition_match do
    status :pending

    after(:build) do |match, _|
      div = if match.home_team || match.away_team
              (match.home_team || match.away_team).division
            else
              create(:division)
            end
      match.home_team = create(:competition_roster, division: div) unless match.home_team
      match.away_team = create(:competition_roster, division: div) unless match.away_team
    end
  end

  factory :bye_match, class: CompetitionMatch do
    status :pending
    away_team nil

    after(:build) do |match, _|
      div = if match.home_team
              match.home_team.division
            else
              create(:division)
            end
      match.home_team = create(:competition_roster, division: div) unless match.home_team
    end
  end
end
