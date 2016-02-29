FactoryGirl.define do
  factory :competition_match do
    status :pending

    after(:build) do |match, _|
      div = create(:division)
      match.home_team = create(:competition_roster, division: div) unless match.home_team
      match.away_team = create(:competition_roster, division: div) unless match.away_team
    end
  end
end
