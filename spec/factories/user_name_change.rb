FactoryGirl.define do
  factory :user_name_change do
    user
    association :approved_by, factory: :user
    denied_by nil
    sequence(:name) { |n| "FOOBAR#{n}" }
  end
end
