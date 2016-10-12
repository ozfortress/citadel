require 'elasticsearch/model'

class Team < ApplicationRecord
  include Searchable

  has_many :invites, dependent: :destroy
  has_many :players,   -> { order(created_at: :desc) }, dependent: :destroy
  has_many :transfers, -> { order(created_at: :desc) }, dependent: :destroy
  has_many :rosters, class_name: 'League::Roster'
  has_many :users, through: :players

  has_many :home_team_matches, through: :rosters, class_name: 'League::Match',
                               foreign_key: 'home_team_id'
  has_many :away_team_matches, through: :rosters, class_name: 'League::Match',
                               foreign_key: 'away_team_id'

  validates :name, presence: true, uniqueness: true, length: { in: 1..64 }
  validates :description, presence: true, allow_blank: true

  mount_uploader :avatar, AvatarUploader

  alias_attribute :to_s, :name

  before_destroy :must_not_have_rosters, prepend: true

  searchable_fields :name
  search_mappings do
    indexes :name, analyzer: 'search'
  end

  def matches
    home_team_matches.union(away_team_matches)
  end

  def invite(user)
    invites.create(user: user)
  end

  def invite_for(user)
    invites.find_by(user: user)
  end

  def invited?(user)
    invites.exists?(user: user)
  end

  def add_player!(user)
    players.create!(user: user)
  end

  def remove_player!(user)
    players.find_by(user: user).destroy!
  end

  def on_roster?(user)
    players.where(user: user).exists?
  end

  def entered?(comp)
    rosters.joins(:division)
           .where(league_divisions: { league_id: comp.id })
           .exists?
  end

  private

  def must_not_have_rosters
    if rosters.exists?
      errors.add(:id, 'can only destroy teams without any rosters')

      throw(:abort)
    end
  end
end
