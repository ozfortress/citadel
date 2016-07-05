class CompetitionTransfer < ActiveRecord::Base
  include Rails.application.routes.url_helpers

  belongs_to :user
  belongs_to :roster, foreign_key: 'competition_roster_id', class_name: 'CompetitionRoster'
  delegate :team,        to: :roster,   allow_nil: true
  delegate :division,    to: :roster,   allow_nil: true
  delegate :competition, to: :division, allow_nil: true

  validates :user, presence: true
  validates :roster, presence: true
  validates :is_joining, inclusion: { in: [true, false] }
  validates :approved, inclusion: { in: [true, false] }
  validate :on_team, on: :create
  validate :within_roster_size, on: :create

  after_initialize :set_defaults, unless: :persisted?

  after_create do
    next unless is_joining?

    msg = if approved?
            "You have been entered in #{competition.name} with '#{roster.name}'."
          else
            "It has been requested for you to transfer into '#{roster.name}' "\
            "for #{competition.name}."
          end

    user.notify!(msg, league_roster_path(competition, roster))
  end

  after_create do
    next if is_joining?

    msg = if approved?
            "You have been removed from '#{roster.name}' for #{competition.name}."
          else
            "It has been requested for you to transfer out of '#{roster.name}' "\
            "for #{competition.name}."
          end

    user.notify!(msg, league_roster_path(competition, roster))
  end

  after_update do
    next unless approved?

    if is_joining?
      user_msg = "The request to transfer into '#{roster.name}' for #{competition.name} "\
                 'has been approved.'
      capt_msg = "The request to transfer '#{user.name}' into '#{roster.name}' for "\
                 "#{competition.name} has been approved."
    else
      user_msg = "The request to transfer out of '#{roster.name}' for #{competition.name} "\
                 'has been approved.'
      capt_msg = "The request to transfer '#{user.name}' out of '#{roster.name}' for "\
                 "#{competition.name} has been approved."
    end

    user.notify!(user_msg, league_roster_path(competition, roster))
    User.get_revokeable(:edit, team).each do |captain|
      captain.notify!(capt_msg, user_path(user))
    end
  end

  before_destroy do
    if is_joining?
      user_msg = "The request to transfer into '#{roster.name}' for #{competition.name} "\
                 'has been denied.'
      capt_msg = "The request to transfer '#{user.name}' into '#{roster.name}' for "\
                 "#{competition.name} has been denied."
    else
      user_msg = "The request to transfer out of '#{roster.name}' for #{competition.name} "\
                 'has been denied.'
      capt_msg = "The request to transfer '#{user.name}' out of '#{roster.name}' for "\
                 "#{competition.name} has been denied."
    end

    user.notify!(user_msg, league_roster_path(competition, roster))
    User.get_revokeable(:edit, team).each do |captain|
      captain.notify!(capt_msg, user_path(user))
    end
  end

  before_update do
    next unless approved? && is_joining

    transfers = competition.players.where(user: user, approved: true)
    if transfers.exists?
      transfers.first.roster.remove_player!(user, approved: true)
    end
  end

  private

  def set_defaults
    if competition.present? && user.present? &&
       (!competition.transfers_require_approval? || !roster.approved?)
      self.approved = !is_joining? || !competition.on_roster?(user)
    end
  end

  def on_team
    return unless user.present? && roster.present?

    if is_joining?
      on_team_for_joining
    else
      on_team_for_leaving
    end
  end

  def on_team_for_joining
    unless roster.team.on_roster?(user) && !roster.on_roster?(user)
      errors.add(:user_id, 'must be on the team to get transferred to the roster')
    end
  end

  def on_team_for_leaving
    unless roster.on_roster?(user)
      errors.add(:user_id, 'must be on the roster to get transferred out')
    end
  end

  def within_roster_size
    return unless roster.present? && roster.persisted? && competition.present?

    if is_joining?
      within_roster_size_for_joining
    else
      within_roster_size_for_leaving
    end
  end

  def within_roster_size_for_joining
    if roster.players.size == competition.max_players
      errors.add(:user_id, 'transferring in would make the roster too large')
    end
  end

  def within_roster_size_for_leaving
    if roster.players.size == competition.min_players
      errors.add(:user_id, 'transferring out would make the roster too small')
    end
  end
end
