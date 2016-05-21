require 'rails_helper'
require 'support/devise'
require 'support/factory_girl'

describe 'layouts/application.html.haml' do
  context 'when unauthenticated' do
    it 'displays steam login' do
      view.lookup_context.prefixes = %w(application)

      render

      expect(rendered).to include('assets/steam/login')
    end
  end

  context 'when authenticated' do
    let(:user) { create(:user) }

    it 'displays username' do
      view.lookup_context.prefixes = %w(application)
      sign_in(user)

      render

      expect(rendered).to include(user.name)
    end
  end

  context 'when meta authorized' do
    let(:user) { create(:user) }

    before do
      user.grant(:edit, :games)
    end

    it 'displays admin link' do
      view.lookup_context.prefixes = %w(application)
      sign_in(user)

      render

      expect(rendered).to include('Admin')
    end
  end
end
