require 'rails_helper'
require 'support/devise'
require 'support/factory_girl'

describe 'users/edit.html.haml' do
  let!(:user) { create(:user) }

  it 'shows form' do
    assign(:user, user)

    render
  end
end
