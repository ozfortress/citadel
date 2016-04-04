require 'elasticsearch/model'

class Team < ActiveRecord::Base
  include Searchable
  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks
  include Roster

  has_many :team_invites
  has_many :transfers
  has_many :competition_rosters

  validates :name, presence: true, uniqueness: true, length: { in: 1..64 }
  validates :description, presence: true, allow_blank: true

  mount_uploader :avatar, AvatarUploader

  def invite(user)
    team_invites.create(user: user)
  end

  def invited?(user)
    team_invites.exists?(user: user)
  end

  def entered?(comp)
    CompetitionRoster.joins(:division)
                     .where(divisions: { competition_id: comp.id })
                     .where(team: self)
                     .exists?
  end

  alias_attribute :to_s, :name

  def self.simple_search(q)
    search(query: { simple_query_string: { query: q } })
  end
end
