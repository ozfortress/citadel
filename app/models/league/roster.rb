class League
  class Roster < ApplicationRecord
    include MarkdownRenderCaching

    belongs_to :team
    belongs_to :division, inverse_of: :rosters
    delegate :league, to: :division, allow_nil: true

    has_many :players, -> { order(created_at: :desc) },
             dependent: :destroy, inverse_of: :roster
    has_many :users, through: :players

    has_many :transfers, -> { order(created_at: :desc) },
             dependent: :destroy, inverse_of: :roster

    has_many :transfer_requests, -> { order(created_at: :desc) },
             dependent: :destroy, inverse_of: :roster

    accepts_nested_attributes_for :players, reject_if: proc { |attrs| attrs['user_id'].blank? }

    has_many :home_team_matches, class_name: 'Match', foreign_key: 'home_team_id'
    has_many :away_team_matches, class_name: 'Match', foreign_key: 'away_team_id'

    has_many :titles, class_name: 'User::Title'
    has_many :comments, class_name: 'Roster::Comment', inverse_of: :roster,
                        dependent: :destroy

    validates :name, presence: true, uniqueness: { scope: :division_id }, length: { in: 1..64 }
    validates :description, presence: true, allow_blank: true, length: { in: 0..500 }
    caches_markdown_render_for :description

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
    scope :ordered, ->(league) { order(Roster.order_keys(league)) }
    scope :seeded, -> { order(seeding: :asc) }
    scope :tied, ->(points) { active.where(points: points) }

    # rubocop:disable Rails/SkipsModelValidations
    after_create { League.increment_counter(:rosters_count, league.id) }
    after_destroy { League.decrement_counter(:rosters_count, league.id) }
    # rubocop:enable Rails/SkipsModelValidations

    after_initialize :set_defaults, unless: :persisted?

    def matches
      Match.for_roster(self)
    end

    def won_matches
      Match.winner(self)
    end

    def drawn_matches
      matches.drawn
    end

    def lost_matches
      Match.loser(self)
    end

    def rounds
      Match::Round.where(match: matches)
    end

    def won_rounds
      Match::Round.winner(self)
    end

    def drawn_rounds
      rounds.drawn
    end

    def lost_rounds
      Match::Round.loser(self)
    end

    def won_rounds_against_tied_rosters
      won_rounds.for_roster(tied_rosters)
    end

    def tied_rosters(points = nil)
      points ||= self.points
      division.rosters.tied(points).where.not(id: id)
    end

    def update_match_counters!
      # Keep old points for updating tied rosters
      old_points = points

      assign_updated_match_counters
      save!(validate: false)

      # Update tied counts on relevant rosters (from old and new points)
      Roster.update_tied_match_counters!(division, points)
      Roster.update_tied_match_counters!(division, old_points) if old_points != points
    end

    def self.update_tied_match_counters!(division, points)
      rosters = division.rosters.tied(points)
      count = Match::Round.joins(:match).select('COUNT(*)').reorder(nil).loser(rosters)
                          .where('league_match_rounds.winner_id = league_rosters.id')

      # rubocop:disable Rails/SkipsModelValidations
      rosters.update_all("won_rounds_against_tied_rosters_count = (#{count.to_sql})")
      # rubocop:enable Rails/SkipsModelValidations
    end

    def disband
      transaction do
        forfeit_all!
        # rubocop:disable Rails/SkipsModelValidations
        transfer_requests.pending.update_all(status: 'denied')
        # rubocop:enable Rails/SkipsModelValidations
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

    def schedule_data=(data)
      self[:schedule_data] = if league.scheduler
                               league.scheduler.transform_data(data)
                             end
    end

    def self.order_keys(league)
      orderings = []
      orderings << 'ranking ASC NULLS LAST'
      orderings << 'CASE WHEN disbanded THEN 0 ELSE points END DESC'
      orderings += league.tiebreakers.map(&:order)
      orderings << 'seeding ASC'
      orderings
    end

    private

    # rubocop:disable Metrics/MethodLength
    def assign_updated_match_counters
      count = ->(query) { query.reorder(nil).select('COUNT(*)').to_sql }
      query = ActiveRecord::Base.connection.exec_query(%{
        SELECT (#{calculate_total_scores_query}) AS total_scores,
               (#{count.call(won_rounds)})       AS won_rounds_count,
               (#{count.call(drawn_rounds)})     AS drawn_rounds_count,
               (#{count.call(lost_rounds)})      AS lost_rounds_count,
               (#{count.call(won_matches)})      AS won_matches_count,
               (#{count.call(drawn_matches)})    AS drawn_matches_count,
               (#{count.call(lost_matches)})     AS lost_matches_count
      })

      assign_attributes(query.to_hash[0])
      # Calculate points after assigning aggregates
      self.points = calculate_points
    end
    # rubocop:enable Metrics/MethodLength

    def calculate_points
      local_counts = [won_rounds_count, drawn_rounds_count, lost_rounds_count,
                      won_matches_count, lost_matches_count]
      comp_counts = league.point_multipliers

      local_counts.zip(comp_counts).map { |x, y| x * y }.sum
    end

    def calculate_total_scores_query
      subquery = ->(rounds, col) { rounds.reorder(nil).select("COALESCE(SUM(#{col}), 0)") }
      rounds = Match::Round.joins(:match).merge(Match.confirmed.no_forfeit).with_outcome

      "(#{subquery.call(rounds.merge(home_team_matches), 'home_team_score').to_sql}) + "\
        "(#{subquery.call(rounds.merge(away_team_matches), 'away_team_score').to_sql})"
    end

    def forfeit_all!
      matches.find_each do |match|
        match.forfeit!(self)
      end
    end

    def set_defaults
      self.approved = false unless approved.present?

      if league.present? && league.scheduler && !schedule_data
        self[:schedule_data] = league.scheduler.default_schedule
      end
    end

    def within_roster_size_limits
      return unless league.present?

      unless league.valid_roster_size?(players.size)
        errors.add(:players, "must have at least #{league.min_players} players" +
          (league.max_players > 0 ? " and no more than #{league.max_players} players" : ''))
      end
    end

    def unique_within_league
      return unless league.present?

      errors.add(:base, 'can only sign up once') if league.rosters.where(team: team).exists?
    end

    def validate_schedule
      return unless league.present? && league.scheduler

      if schedule_data.present?
        league.scheduler.validate_roster(self)
      else
        errors.add(:schedule_data, 'is required')
      end
    end
  end
end
