FactoryGirl.define do
  factory :user_name_change do
    user
    denied_by nil
    sequence(:name) { |n| "FOOBAR#{n}" }
  end
end
