FactoryGirl.define do
  factory :team do
    name 'Immunity'
    description 'We beat everyone'
    format { create(:format) }
  end
end
