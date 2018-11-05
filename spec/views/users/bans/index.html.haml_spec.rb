require 'rails_helper'

describe 'users/bans/index' do
  let(:user) { build_stubbed(:user) }

  let(:bans) do
    [
      user.bans_for(:use, :teams).new(id: 1, user: user, created_at: Time.zone.now),
      user.bans_for(:use, :users).new(id: 2, user: user, created_at: Time.zone.now, duration: 1.hour),
      user.bans_for(:use, :leagues).new(id: 3, user: user, created_at: Time.zone.now - 2.hours, duration: 1.hour),
    ]
  end

  let(:ban_models) do
    User.ban_models.map do |_, bans|
      bans.map { |_, model| model }
    end.reduce(:+).compact
  end

  it 'renders' do
    assign(:user, user)
    assign(:bans, bans)
    assign(:ban_models, ban_models)
    assign(:new_bans, ban_models.map(&:new))

    render
  end
end
