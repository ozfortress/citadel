FactoryGirl.define do
  factory :team do
    name 'Immunity'
    description 'We beat everyone'
    format { Format.first || create(:format) }
  end
end
