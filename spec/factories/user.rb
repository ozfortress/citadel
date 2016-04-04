FactoryGirl.define do
  factory :user do
    sequence(:name) { |n| "FOOBAR#{n}" }
    sequence(:steam_id) { |n| n }

    after(:create) do |user|
      if user.names.empty?
        create(:user_name_change, user: user, approved_by: user, name: user.name)
      end
    end
  end
end
