require 'elasticsearch/model'

class User < ApplicationRecord
  include Transfers
  include Searchable
  include Auth::Model

  has_many :team_invites, class_name: 'Team::Invite'
  has_many :team_transfers, -> { order(created_at: :desc) }, class_name: 'Team::Transfer'
  has_many :roster_transfers, class_name: 'League::Roster::Transfer'
  has_many :titles, -> { order(created_at: :desc) }, class_name: 'Title'
  has_many :names, -> { order(created_at: :desc) }, class_name: 'NameChange'
  has_many :notifications, -> { order(created_at: :desc) }, class_name: 'Notification'
  has_many :forums_subscriptions, class_name: 'Forums::Subscription'

  devise :rememberable, :trackable, :omniauthable, omniauth_providers: [:steam]

  validates :name, presence: true, uniqueness: true, length: { in: 1..64 }
  validates :steam_id, presence: true, uniqueness: true,
                       numericality: { greater_than: 0 }
  validates :description, presence: true, allow_blank: true

  validates_permission_to :edit, :users

  validates_permission_to :edit, :team
  validates_permission_to :edit, :teams

  validates_permission_to :edit, :games

  validates_permission_to :edit, :league
  validates_permission_to :edit, :leagues

  validates_permission_to :manage_rosters, :league
  validates_permission_to :manage_rosters, :leagues

  validates_permission_to :edit, :permissions

  validates_permission_to :manage, :forums
  validates_permission_to :manage, :forums_topic,  class_name: '::Forums::Topic'
  validates_permission_to :manage, :forums_thread, class_name: '::Forums::Thread'

  mount_uploader :avatar, AvatarUploader

  alias_attribute :to_s, :name

  searchable_fields :name, :steam_id, :steam_id_nice
  search_mappings do
    indexes :name, analyzer: 'search'
    indexes :steam_id, analyzer: 'keyword'
    indexes :steam_id_nice, analyzer: 'keyword'
  end

  def steam_profile_url
    "http://steamcommunity.com/profiles/#{steam_id}"
  end

  def teams
    get_player_rosters(team_transfers, :team_id, Team, :team_transfers)
  end

  def rosters
    get_player_rosters(roster_transfers.approved, :roster_id,
                       League::Roster, :league_roster_transfers)
  end

  def matches
    rosters_sql = rosters.select(:id).to_sql
    League::Match.where("home_team_id IN (#{rosters_sql}) OR away_team_id IN (#{rosters_sql})")
  end

  def entered?(comp)
    comp.roster_transfer(self).exists?
  end

  def steam_id_nice
    SteamId.to_str(steam_id)
  end

  def admin?
    can?(:edit, :teams) ||
      can?(:edit, :leagues) ||
      can?(:edit, :games) ||
      can?(:manage_rosters, :leagues) ||
      can?(:edit, :permissions)
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
