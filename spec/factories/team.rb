FactoryGirl.define do
  factory :team do
    sequence(:name) { |n| "Immunity #{n}" }
    description 'We beat everyone'
  end

  factory :team_with_avatar, class: Team, parent: :team do
    after :create do |team|
      team.update_column(:avatar, "spec/support/avatar.png")
    end
  end
end
