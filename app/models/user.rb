require 'auth'

class User < ActiveRecord::Base
  include Auth::Model

  has_many :team_invites
  has_many :transfers

  devise :rememberable, :timeoutable, :trackable,
         :omniauthable, omniauth_providers: [:steam]

  validates :name, presence: true, uniqueness: true, length: { in: 1..64 }
  validates :steam_id, presence: true, uniqueness: true,
                       numericality: { greater_than: 0 }
  validates :description, presence: true, allow_blank: true

  validates_permission_to :edit, :team
  validates_permission_to :edit, :teams

  validates_permission_to :edit, :games

  validates_permission_to :edit, :competition
  validates_permission_to :edit, :competitions

  def steam_profile_url
    "http://steamcommunity.com/profiles/#{steam_id}"
  end

  def teams
    # TODO: Maybe turn this into a big query?
    teams = Set.new
    transfers.each do |transfer|
      if transfer.is_joining?
        teams << transfer.team
      else
        teams.delete(transfer.team)
      end
    end

    teams.to_a.sort! { |a, b| a.name.downcase <=> b.name.downcase }
  end
end
