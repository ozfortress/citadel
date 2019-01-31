class League
  class Roster < ApplicationRecord
    include MarkdownRenderCaching

    belongs_to :team, inverse_of: :rosters
    belongs_to :division, inverse_of: :rosters
    delegate :league, to: :division, allow_nil: true

    has_many :players, -> { order(created_at: :asc) }, dependent: :destroy, inverse_of: :roster
    has_many :users, through: :players

    has_many :transfers, -> { order(created_at: :desc) }, dependent: :destroy, inverse_of: :roster

    has_many :transfer_requests, -> { order(created_at: :desc) }, dependent: :destroy, inverse_of: :roster

    accepts_nested_attributes_for :players, reject_if: proc { |attrs| attrs['user_id'].blank? }

    has_many :home_team_matches, class_name: 'Match', foreign_key: 'home_team_id'
    has_many :away_team_matches, class_name: 'Match', foreign_key: 'away_team_id'

    has_many :titles, class_name: 'User::Title'
    has_many :comments, class_name: 'Roster::Comment', inverse_of: :roster, dependent: :destroy

    validates :name, presence: true, uniqueness: { scope: :division_id }, length: { in: 1..64 }
    validates :description, presence: true, allow_blank: true, length: { in: 0..500 }
    caches_markdown_render_for :description
    validates :notice, presence: true, allow_blank: true
    caches_markdown_render_for :notice

    validates :ranking,   numericality: { greater_than: 0 }, allow_nil: true
    validates :seeding,   numericality: { greater_than: 0 }, allow_nil: true
    validates :approved,  inclusion: { in: [true, false] }
    validates :disbanded, inclusion: { in: [true, false] }

    validate :within_roster_size_limits, on: :create
    validate :unique_within_league, on: :create
    validate :validate_schedule

    scope :approved, -> { where(approved: true) }
    scope :active, -> { approved.where(disbanded: false) }
    scope :for_incomplete_league, lambda {
      completed = League.statuses[:completed]
      includes(division: :league).where.not(leagues: { status: completed })
    }
    scope :for_completed_league, lambda {
      completed = League.statuses[:completed]
      includes(division: :league).where(leagues: { status: completed })
    }
    scope :ordered, -> { order(placement: :asc) }
    scope :seeded, -> { order(seeding: :asc) }

    # rubocop:disable Rails/SkipsModelValidations
    after_create { League.increment_counter(:rosters_count, league.id) }
    after_destroy { League.decrement_counter(:rosters_count, league.id) }
    # rubocop:enable Rails/SkipsModelValidations

    after_initialize :set_defaults, unless: :persisted?

    def self.matches
      Match.for_roster(all.map(&:id))
    end

    def matches
      Match.for_roster(self)
    end

    def disband
      transaction do
        if league.forfeit_all_matches_when_roster_disbands?
          forfeit_all!
        else
          forfeit_all_non_confirmed!
        end

        transfer_requests.pending.destroy_all
        update!(disbanded: true)
      end
    end

    def users_off_roster
      team.users.where.not(id: users)
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

    def tentative_player_count
      players.size + TransferRequest.joining_roster(self).size - TransferRequest.leaving_roster(self).size
    end

    def schedule_data=(data)
      self[:schedule_data] = league.scheduler&.transform_data(data)
    end

    def order_keys_for(league)
      keys = [ranking || Float::INFINITY, disbanded? ? 1 : 0, -points]
      keys += league.tiebreakers.map { |tiebreaker| -tiebreaker.value_for(self) }
      keys.push seeding || Float::INFINITY
      keys
    end

    private

    def forfeit_all!
      matches.find_each do |match|
        match.forfeit!(self)
      end
    end

    def forfeit_all_non_confirmed!
      matches.where.not(status: :confirmed).find_each do |match|
        match.forfeit!(self)
      end
    end

    def set_defaults
      self.approved = false if approved.blank?

      self[:schedule_data] = league.scheduler.default_schedule if league.present? && league.scheduler && !schedule_data
    end

    def within_roster_size_limits
      return if league.blank?

      unless league.valid_roster_size?(players.size)
        errors.add(:players, "Must have at least #{league.min_players} players" +
          (league.max_players.positive? ? " and no more than #{league.max_players} players" : ''))
      end
    end

    def unique_within_league
      return if league.blank?

      errors.add(:base, 'Can only sign up once') if league.rosters.where(team: team).exists?
    end

    def validate_schedule
      return unless league.present? && league.scheduler

      if schedule_data.present?
        league.scheduler.validate_roster(self)
      else
        errors.add(:schedule_data, 'Is required')
      end
    end
  end
end
