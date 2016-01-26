FactoryGirl.define do
  factory :division do
    name "Div 5"
    description "We're not good yet"
    competition { Competition.first || create(:competition) }
  end

end
