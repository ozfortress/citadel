FactoryGirl.define do
  factory :competition_roster do
    team
    division
    sequence(:name) { |n| "Immunity #{n}" }
    description 'We beat everyone'
    points 0
    approved false
  end
end
