FactoryBot.define do
  factory :user_name_change, class: User::NameChange do
    user
    approved_by nil
    denied_by nil
    sequence(:name) { |n| "BARFOO#{n}" }
  end
end
