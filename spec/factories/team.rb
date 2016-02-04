FactoryGirl.define do
  factory :team do
    sequence(:name) { |n| "Immunity #{n}" }
    description 'We beat everyone'
  end
end
