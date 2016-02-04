FactoryGirl.define do
  factory :transfer do
    user
    team
    is_joining? true
  end
end
