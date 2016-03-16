require 'rails_helper'
require 'support/devise'
require 'support/factory_girl'

describe 'users/show.html.haml' do
  let(:user) { create(:user) }

  it 'shows user data' do
    assign(:user, user)

    render

    expect(rendered).to include(user.name)
    # TODO: Add more checks for user data
  end
end
