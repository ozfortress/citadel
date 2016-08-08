FactoryGirl.define do
  factory :league do
    sequence(:name) { |n| "OWL #{n}" }
    description "The owl that won't happen"
    format
    status :hidden
    signuppable false
    roster_locked false
    matches_submittable false
    transfers_require_approval true
    min_players 1
    max_players 0
  end
end
