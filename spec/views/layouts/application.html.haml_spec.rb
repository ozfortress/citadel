require 'spec_helper'
require 'support/devise'
require 'support/shoulda'
require 'support/factory_girl'

describe 'layouts/application.html.haml' do
  context 'when unauthenticated' do
    before do
      def view.user_can_meta?
        false
      end
    end

    it 'displays steam login' do
      render

      expect(rendered).to include('assets/steam/login')
    end
  end

  context 'when authenticated' do
    pending 'test'
  end

  context 'when meta authorized' do
    pending 'test'
  end
end
