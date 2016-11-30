FactoryGirl.define do
  factory :league_match_comm_edit, class: 'League::Match::CommEdit' do
    user
    association :comm, factory: :league_match_comm
    content 'hi'
  end
end
