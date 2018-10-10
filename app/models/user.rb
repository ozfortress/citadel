require 'search'
require 'auth'
require 'steam_id'

class User < ApplicationRecord
  include Auth::Model
  include MarkdownRenderCaching

  EMAIL_CONFIRMATION_TIMEOUT = 1.hour

  has_many :titles, -> { order(created_at: :desc) }
  has_many :names, -> { order(created_at: :desc) }, class_name: 'NameChange'
  has_many :notifications, -> { order(created_at: :desc) }, inverse_of: :user
  has_many :forums_subscriptions, class_name: 'Forums::Subscription'

  has_many :team_players, class_name: 'Team::Player'
  private :team_players, :team_players=
  has_many :teams, through: :team_players
  has_many :team_invites, class_name: 'Team::Invite'
  has_many :team_transfers, -> { order(created_at: :desc) }, class_name: 'Team::Transfer'

  has_many :roster_players, class_name: 'League::Roster::Player'
  private :roster_players, :roster_players=
  has_many :rosters, through: :roster_players, class_name: 'League::Roster'
  has_many :roster_transfers,         class_name: 'League::Roster::Transfer'
  has_many :roster_transfer_requests, class_name: 'League::Roster::TransferRequest'

  has_many :comments, class_name: 'User::Comment'

  has_many :forums_posts, class_name: 'Forums::Post', inverse_of: :created_by, foreign_key: :created_by
  has_many :public_forums_posts, -> { publicly_viewable }, class_name: 'Forums::Post', foreign_key: :created_by

  devise :rememberable, :trackable, :omniauthable, omniauth_providers: [:steam]

  validates :name, presence: true, uniqueness: true, length: { in: 1..64 }
  validates :steam_id, presence: true, uniqueness: true,
                       numericality: { greater_than: 0 }
  validates :description, presence: true, allow_blank: true, length: { in: 0..500 }
  caches_markdown_render_for :description
  validates :email, allow_blank: true, format: { with: /@/ } # How you actually validate emails
  validates :notice, presence: true, allow_blank: true
  caches_markdown_render_for :notice

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

  validates_prohibition_to :use, :users

  validates_prohibition_to :use, :teams

  validates_prohibition_to :use, :leagues

  validates_prohibition_to :use, :forums
  validates_prohibition_to :use, :forums_topic,  class_name: '::Forums::Topic'
  validates_prohibition_to :use, :forums_thread, class_name: '::Forums::Thread'

  mount_uploader :avatar, AvatarUploader

  alias_attribute :steam_64, :steam_id

  before_save :update_query_cache

  scope :search, (lambda do |query|
    return order(:id) if query.blank?

    steam_id = SteamId.to_64(query)
    query = Search.transform_query(query)

    where(steam_id: steam_id).or(where('(query_name_cache <-> ?) < 0.9', query))
      .order(sanitize_sql_for_order([Arel.sql('steam_id = ? DESC'), steam_id]))
      .order(sanitize_sql_for_order([Arel.sql('query_name_cache <-> ?'), query]))
  end)

  def matches
    League::Match.where(home_team: rosters).or(League::Match.where(away_team: rosters))
  end

  def entered?(comp)
    comp.players(user: self).exists?
  end

  def authorized_teams_for(league)
    can_for(:edit, :team).select do |team|
      team.players_count >= league.min_players && !team.entered?(league)
    end
  end

  def steam_32
    SteamId.to_32(steam_id)
  end

  def steam_id3
    SteamId.to_id3(steam_id)
  end

  def admin?
    User.admin_grants.any? { |action, subject| can?(action, subject) }
  end

  def badge?
    badge_name.present?
  end

  def aka
    names.approved.where.not(name: name)
  end

  def distinct_ips
    Visit.select('DISTINCT ON (ip) ip').reorder('ip').where(user: self)
  end

  def notify!(message, link)
    notifications.create!(message: message, link: link)
  end

  def confirm
    update(confirmed_at: Time.current)
  end

  def generate_confirmation_token
    self.confirmed_at = nil
    self.confirmation_sent_at = Time.current
    self.confirmation_token = SecureRandom.urlsafe_base64(64)
  end

  def confirmation_timed_out?
    (Time.current - confirmation_sent_at) > EMAIL_CONFIRMATION_TIMEOUT
  end

  def confirmed?
    !confirmed_at.nil? && email.present?
  end

  # Always remember using devise rememberable
  def remember_me
    true
  end

  def reset_query_cache!
    update_query_cache
    save!
  end

  def self.admin_grants
    [[:edit, :teams], [:edit, :leagues], [:edit, :games],
     [:manage_rosters, :leagues], [:edit, :permissions]]
  end

  def self.admin_associations
    admin_grants.map { |action, subject| grant_model_for(action, subject).association_name }
  end

  private

  def update_query_cache
    self.query_name_cache = I18n.transliterate(name)
  end

  def get_player_rosters(transfers, transfer_sort, rosters, rosters_sort)
    # TODO: transfer_sort and rosters_sort can be inferred
    ids = player_transfers(transfers, transfer_sort)
    rosters.joins(:transfers)
           .where(rosters_sort => { id: ids, is_joining: true })
           .order(:name)
  end
end
