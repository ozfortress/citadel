require 'rails_helper'
require 'support/devise'
require 'support/factory_girl'

describe 'pages/home.html.haml' do
  let(:user) { create(:user) }

  it 'renders for the unauthenticated' do
    render
  end

  it 'renders for the authenticated' do
    sign_in user

    render
  end
end
