require 'rails_helper'

describe 'layouts/application' do
  before do
    view.lookup_context.prefixes = %w(application)
  end

  context 'when unauthenticated' do
    it 'displays steam login' do
      render

      expect(rendered).to include('assets/steam/login')
    end
  end

  context 'when authenticated' do
    let(:user) { create(:user) }

    before do
      assign(:notifications, build_stubbed_list(:user_notification, 10, user: user))
    end

    it 'displays username' do
      sign_in user

      render

      expect(rendered).to include(user.name)
    end

    context 'when meta authorized' do
      before do
        user.grant(:edit, :games)
      end

      it 'displays admin link' do
        sign_in user

        render

        expect(rendered).to include('Admin')
      end
    end
  end
end
