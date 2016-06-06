require 'rails_helper'
require 'support/devise'
require 'support/factory_girl'

describe TeamInvitesController do
  let(:user) { create(:user) }
  let(:team) { create(:team) }

  describe 'PATCH #accept' do
    it 'accepts an invite' do
      invite = team.invite(user)

      sign_in user
      request.env['HTTP_REFERER'] = users_path
      patch :accept, id: invite.id

      expect(team.invited?(user)).to be(false)
      expect(team.on_roster?(user)).to be(true)
      expect(response).to redirect_to(users_path)
    end
  end

  describe 'PATCH #decline' do
    it 'declines an invite' do
      invite = team.invite(user)

      sign_in user
      request.env['HTTP_REFERER'] = users_path
      patch :decline, id: invite.id

      expect(team.invited?(user)).to be(false)
      expect(team.on_roster?(user)).to be(false)
      expect(response).to redirect_to(users_path)
    end
  end
end
