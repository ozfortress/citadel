require 'rails_helper'

describe 'users/new' do
  it 'shows form' do
    assign(:user, build(:user))

    render
  end
end
