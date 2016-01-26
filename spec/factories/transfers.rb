FactoryGirl.define do
  factory :transfer do
    user { create(:user) }
    team { create(:team) }
    is_joining? true
  end
end
