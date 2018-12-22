FactoryBot.define do
  factory :user_log, class: User::Log do
    user
    ip { |n| "127.0.0.#{n + 1}" }
    first_seen_at { Time.now.utc }
    last_seen_at { Time.now.utc }
  end
end
