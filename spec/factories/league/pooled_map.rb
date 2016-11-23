FactoryGirl.define do
  factory :league_pooled_map, class: 'League::PooledMap' do
    league
    map
  end
end
