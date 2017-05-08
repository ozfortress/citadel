require 'rails_helper'

describe 'layouts/application' do
  context 'when unauthenticated' do
    it 'displays steam login' do
      render

      expect(rendered).to include('assets/steam/login')
      expect(rendered).to_not include('Admin')
    end
  end

  context 'when authenticated' do
    let(:user) { build_stubbed(:user) }

    before do
      allow(user).to receive(:teams).and_return(build_stubbed_list(:team, 2))
      allow(view).to receive(:current_user).and_return(user)
      allow(view).to receive(:user_signed_in?).and_return(true)
      assign(:notifications, build_stubbed_list(:user_notification, 10, user: user))
    end

    it 'displays username' do
      sign_in user

      render

      expect(rendered).to_not include('assets/steam/login')
      expect(rendered).to include(user.name)
      expect(rendered).to_not include('Admin')
    end

    context 'when meta authorized' do
      before do
        allow(user).to receive(:admin?).and_return(true)
      end

      it 'displays admin link' do
        sign_in user

        render

        expect(rendered).to_not include('assets/steam/login')
        expect(rendered).to include(user.name)
        expect(rendered).to include('Admin')
      end
    end
  end
end
