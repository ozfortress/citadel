FactoryBot.define do
  factory :map do
    game
    sequence(:name) { |n| "cp_process_rc#{n}" }
    description { 'Best map' }
  end
end
