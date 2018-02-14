FactoryBot.define do
  factory :league_division, class: League::Division do
    sequence(:name) { |n| "Div #{n}" }
    league
  end
end
