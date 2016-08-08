FactoryGirl.define do
  factory :user_title, class: User::Title do
    user
    league nil
    roster nil
    sequence(:name) { |n| "Won #{n}th League" }
  end
end
