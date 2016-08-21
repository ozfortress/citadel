require 'rails_helper'
require 'support/devise'
require 'support/factory_girl'

describe 'users/index' do
  let!(:user1) { create(:user) }
  let!(:user2) { create(:user) }

  before do
    view.lookup_context.prefixes = %w(application)
  end

  it 'shows all users' do
    assign(:users, User.paginate(page: 1))

    render

    expect(rendered).to include(user1.name)
    expect(rendered).to include(user2.name)
  end
end
