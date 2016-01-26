FactoryGirl.define do
  factory :competition do
    name 'OWL 333'
    description "The owl that won't happen"
    format { Format.first || create(:format) }
  end
end
