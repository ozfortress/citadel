FactoryGirl.define do
  factory :user do
    sequence(:name) { |n| "FOOBAR#{n}" }
    sequence(:steam_id) { |n| n }
  end

  factory :user_with_avatar, class: User, parent: :user do
    after :create do |user|
      user.update_column(:avatar, "spec/support/avatar.png")
    end
  end
end
