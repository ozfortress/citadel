FactoryGirl.define do
  factory :user_comment, class: User::Comment do
    user
    association :created_by, factory: :user
    content 'This person should get banned'
  end
end
