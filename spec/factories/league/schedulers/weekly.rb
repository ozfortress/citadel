FactoryBot.define do
  factory :league_schedulers_weekly, class: League::Schedulers::Weekly do
    league
    start_of_week 'Sunday'
    minimum_selected 3
    days Array.new(7, true)
  end
end
