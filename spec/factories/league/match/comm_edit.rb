FactoryGirl.define do
  factory :league_match_comm_edit, class: 'League::Match::CommEdit' do
    association :created_by, factory: :user
    association :comm, factory: :league_match_comm
    sequence(:content) { |n| "Can we play at #{n}:00pm" }
  end
end
