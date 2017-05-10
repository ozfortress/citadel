require 'rails_helper'

describe 'users/index' do
  let(:users) { build_stubbed_list(:user, 3) }

  before do
    users.first.badge_name = 'Admin'
  end

  it 'shows all users' do
    assign(:users, users.paginate(page: 1))

    render

    users.each do |user|
      expect(rendered).to include(user.name)
    end
  end
end
