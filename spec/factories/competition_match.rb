FactoryGirl.define do
  factory :competition_match do
    association :home_team, factory: :competition_roster
    association :away_team, factory: :competition_roster
    status :pending

    after(:build) do |match, _|
      div = create(:division)
      match.home_team = create(:competition_roster, division: div)
      match.away_team = create(:competition_roster, division: div)
    end
  end
end
