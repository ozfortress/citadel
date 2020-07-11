require 'rails_helper'

describe 'admin/index' do
  context 'when meta authorized' do
    let(:user) { create(:user) }

    before do
      user.grant(:edit, :games)
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
      user.grant(:edit, :users)
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
