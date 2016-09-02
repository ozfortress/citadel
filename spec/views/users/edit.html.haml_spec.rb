require 'rails_helper'

describe 'users/edit' do
  let!(:user) { create(:user) }

  it 'shows form' do
    assign(:user, user)
    assign(:name_change, user.names.new(name: user.name))

    render
  end
end
