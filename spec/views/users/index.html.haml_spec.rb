require 'rails_helper'
require 'support/devise'
require 'support/factory_girl'

describe 'users/index.html.haml' do
  let!(:user1) { create(:user) }
  let!(:user2) { create(:user) }

  it 'shows all users' do
    view.lookup_context.prefixes = %w(application)
    assign(:users, User.all)

    render

    expect(rendered).to include(user1.name)
    expect(rendered).to include(user2.name)
  end
end
