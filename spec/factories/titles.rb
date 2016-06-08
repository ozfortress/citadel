FactoryGirl.define do
  factory :title do
    user
    competition nil
    competition_roster nil
    sequence(:name) { |n| "Won #{n}th League" }
  end
end
