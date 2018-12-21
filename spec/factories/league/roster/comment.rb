FactoryBot.define do
  factory :league_roster_comment, class: League::Roster::Comment do
    association :created_by, factory: :user
    association :roster, factory: :league_roster
    content { 'This team is full of unorganised idiots' }
    content_render_cache { 'This team is full of unorganised idiots' }
  end
end
