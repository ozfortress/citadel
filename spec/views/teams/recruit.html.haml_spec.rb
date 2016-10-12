require 'rails_helper'

describe 'teams/recruit' do
  let(:team) { create(:team) }
  let!(:users) { create_list(:user, 4) }

  it 'shows all users' do
    pending "Doesn't work due to _search using 'fullpath'"
    assign(:team, team)
    assign(:users, User.paginate(page: 1))

    render

    users.each do |user|
      expect(rendered).to include(user.name)
    end
  end
end
