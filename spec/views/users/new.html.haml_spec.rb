require 'rails_helper'
require 'support/devise'
require 'support/factory_girl'

describe 'users/new' do
  it 'shows form' do
    assign(:user, build(:user))

    render
  end
end
