require 'rails_helper'
require 'support/devise'
require 'support/factory_girl'

describe 'teams/recruit.html.haml' do
  let(:team) { create(:team) }
  let!(:users) { create_list(:user, 4) }

  it 'shows all users' do
    pending "Doesn't work due to _search using 'fullpath'"
    view.lookup_context.prefixes = %w(application)
    assign(:team, team)
    assign(:users, User.paginate(page: 1))

    render

    users.each do |user|
      expect(rendered).to include(user.name)
    end
  end
end
