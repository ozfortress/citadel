require 'rails_helper'
require 'support/devise'
require 'support/factory_girl'

describe 'admin/index.html.haml' do
  context 'when competitions authorized' do
    let(:user) { create(:user) }

    before do
      user.grant(:edit, :competitions)
    end

    it 'displays username' do
      sign_in(user)

      render

      expect(rendered).to include('Leagues')
      expect(rendered).to_not include('Meta')
    end
  end

  context 'when meta authorized' do
    let(:user) { create(:user) }

    before do
      user.grant(:edit, :games)
    end

    it 'displays admin link' do
      sign_in(user)

      render

      expect(rendered).to include('Meta')
      expect(rendered).to_not include('Leagues')
    end
  end
end
