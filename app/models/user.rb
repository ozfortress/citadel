require 'auth'

class User < ActiveRecord::Base
  include Auth::Model

  devise :rememberable, :timeoutable, :trackable,
         :omniauthable, omniauth_providers: [:steam]

  validates :name, presence: true, uniqueness: true, length: { in: 1..64 }
  validates :steam_id, presence: true, uniqueness: true,
                       numericality: { greater_than: 0 }

  validates_permission_to :edit, :team
  validates_permission_to :edit, :teams

  validates_permission_to :edit, :games

  def steam_profile_url
    "http://steamcommunity.com/profiles/#{steam_id}"
  end
end
