FactoryBot.define do
  factory :game do
    sequence(:name) { |n| "Team Fortress #{n}" }
  end
end
