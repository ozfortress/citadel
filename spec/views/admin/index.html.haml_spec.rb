require 'rails_helper'
require 'support/auth'
require 'support/devise'
require 'support/factory_girl'

describe 'admin/index' do
  context 'when leagues authorized' do
    let(:user) { build_stubbed(:user) }

    before do
      stub_auth(user, :edit, :leagues)
    end

    it 'displays username' do
      sign_in user

      render

      expect(rendered).to include('Leagues')
      expect(rendered).to_not include('Meta')
      expect(rendered).to_not include('Name Changes')
    end
  end

  context 'when meta authorized' do
    let(:user) { build_stubbed(:user) }

    before do
      stub_auth(user, :edit, :games)
    end

    it 'displays admin link' do
      sign_in user

      render

      expect(rendered).to include('Meta')
      expect(rendered).to_not include('Leagues')
      expect(rendered).to_not include('Name Changes')
    end
  end

  context 'when users authorized' do
    let(:user) { create(:user) }

    before do
      stub_auth(user, :edit, :users)
    end

    it 'displays name changes link' do
      sign_in user

      render

      expect(rendered).to include('Name Changes')
      expect(rendered).to_not include('Leagues')
      expect(rendered).to_not include('Meta')
    end
  end
end
