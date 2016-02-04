FactoryGirl.define do
  factory :competition_roster do
    team
    division
    points 0
    approved false
  end
end
