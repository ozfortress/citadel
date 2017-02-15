FactoryGirl.define do
  factory :league_match_comm_edit, class: 'League::Match::CommEdit' do
    user
    association :comm, factory: :league_match_comm
    sequence(:content) { |n| "Can we play at #{n}:00pm" }
  end
end
