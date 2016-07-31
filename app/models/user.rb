require 'elasticsearch/model'

require 'auth'
require 'steam_id'

class User < ActiveRecord::Base
  include Transfers
  include Searchable
  include Auth::Model

  has_many :team_invites
  has_many :transfers, -> { order(created_at: :desc) }
  has_many :roster_transfers, class_name: 'CompetitionTransfer'
  has_many :titles, -> { order(created_at: :desc) }
  has_many :names, -> { order(created_at: :desc) }, class_name: 'UserNameChange'
  has_many :notifications, -> { order(created_at: :desc) }

  devise :rememberable, :trackable, :omniauthable, omniauth_providers: [:steam]

  validates :name, presence: true, uniqueness: true, length: { in: 1..64 }
  validates :steam_id, presence: true, uniqueness: true,
                       numericality: { greater_than: 0 }
  validates :description, presence: true, allow_blank: true

  validates_permission_to :edit, :users

  validates_permission_to :edit, :team
  validates_permission_to :edit, :teams

  validates_permission_to :edit, :games

  validates_permission_to :edit, :competition
  validates_permission_to :edit, :competitions

  validates_permission_to :manage_rosters, :competition
  validates_permission_to :manage_rosters, :competitions

  validates_permission_to :edit, :permissions

  mount_uploader :avatar, AvatarUploader

  alias_attribute :to_s, :name

  def steam_profile_url
    "http://steamcommunity.com/profiles/#{steam_id}"
  end

  def teams
    get_player_rosters(transfers, :team_id, Team, :transfers)
  end

  def rosters
    get_player_rosters(roster_transfers, :competition_roster_id,
                       CompetitionRoster, :competition_transfers)
  end

  def matches
    rosters_sql = rosters.select(:id).to_sql
    CompetitionMatch.where("home_team_id IN (#{rosters_sql}) OR away_team_id IN (#{rosters_sql})")
  end

  def entered?(comp)
    comp.roster_transfer(self).exists?
  end

  def steam_id_nice
    SteamId.to_str(steam_id)
  end

  def admin?
    can?(:edit, :teams) ||
      can?(:edit, :competitions) ||
      can?(:edit, :games) ||
      can?(:manage_rosters, :competitions) ||
      can?(:edit, :permissions)
  end

  def as_indexed_json(_ = {})
    as_json(only: [:name, :steam_id],
            methods: [:steam_id_nice])
  end

  def pending_names
    names.where(approved_by: nil, denied_by: nil)
  end

  def approved_names
    names.where.not(approved_by: nil)
  end

  def aka
    approved_names.where.not(name: name)
  end

  def unread_notifications
    notifications.where(read: false)
  end

  def notify!(message, link)
    notifications.create!(message: message, link: link)
  end

  # Always remember using devise rememberable
  def remember_me
    true
  end

  private

  def get_player_rosters(transfers, transfer_sort, rosters, rosters_sort)
    # TODO: transfer_sort and rosters_sort can be inferred
    ids = player_transfers(transfers, transfer_sort)
    rosters.joins(:transfers)
           .where(rosters_sort => { id: ids, is_joining: true })
           .order(:name)
  end
end
