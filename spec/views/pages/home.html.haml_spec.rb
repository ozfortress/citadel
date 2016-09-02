require 'rails_helper'

describe 'pages/home' do
  let(:user) { create(:user) }

  it 'renders for the unauthenticated' do
    render
  end

  it 'renders for the authenticated' do
    sign_in user

    render
  end
end
