class League
  class Roster < ApplicationRecord
    belongs_to :team
    belongs_to :division, inverse_of: :rosters
    delegate :league, to: :division, allow_nil: true

    has_many :players,           -> { order(created_at: :desc) }, dependent: :destroy,
                                                                  inverse_of: :roster
    has_many :transfers,         -> { order(created_at: :desc) }, dependent: :destroy,
                                                                  inverse_of: :roster
    has_many :transfer_requests, -> { order(created_at: :desc) }, dependent: :destroy,
                                                                  inverse_of: :roster
    has_many :users, through: :players

    accepts_nested_attributes_for :players, reject_if: proc { |attrs| attrs['user_id'].blank? }

    has_many :home_team_matches, class_name: 'Match', foreign_key: 'home_team_id'
    has_many :home_team_rounds, through: :home_team_matches, source: :rounds
    has_many :not_forfeited_home_team_matches, -> { not_forfeited }, class_name: 'Match',
                                                                     foreign_key: 'home_team_id'
    has_many :not_forfeited_home_team_rounds, through: :not_forfeited_home_team_matches,
                                              source: :rounds

    has_many :away_team_matches, class_name: 'Match', foreign_key: 'away_team_id'
    has_many :away_team_rounds, through: :away_team_matches, source: :rounds
    has_many :not_forfeited_away_team_matches, -> { not_forfeited }, class_name: 'Match',
                                                                     foreign_key: 'away_team_id'
    has_many :not_forfeited_away_team_rounds, through: :not_forfeited_away_team_matches,
                                              source: :rounds

    has_many :titles, class_name: 'User::Title'
    has_many :comments, class_name: 'Roster::Comment', inverse_of: :roster,
                        dependent: :destroy

    validates :team,        uniqueness: { scope: :division_id }
    validates :name,        presence: true, uniqueness: { scope: :division_id },
                            length: { in: 1..64 }
    validates :description, presence: true, allow_blank: true
    validates :ranking,     numericality: { greater_than: 0 }, allow_nil: true
    validates :seeding,     numericality: { greater_than: 0 }, allow_nil: true
    validates :approved,    inclusion: { in: [true, false] }
    validates :disbanded,   inclusion: { in: [true, false] }

    validate :within_roster_size_limits, on: :create
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

    after_create do
      League.increment_counter(:rosters_count, league.id)
    end

    after_destroy do
      League.decrement_counter(:rosters_count, league.id)
    end

    after_initialize :set_defaults, unless: :persisted?

    def matches
      home_team_matches.union(away_team_matches)
                       .order(round: :desc, created_at: :asc)
    end

    def won_rounds
      away_won = not_forfeited_away_team_rounds.away_team_wins
      not_forfeited_home_team_rounds.home_team_wins.union(away_won)
    end

    def drawn_rounds
      not_forfeited_home_team_rounds.union(not_forfeited_away_team_rounds).draws
    end

    def lost_rounds
      away_lost = not_forfeited_away_team_rounds.home_team_wins
      not_forfeited_home_team_rounds.away_team_wins.union(away_lost)
    end

    def forfeit_won_matches
      away_forfeit = home_team_matches.away_team_forfeited
      away_team_matches.home_team_forfeited.union(away_forfeit)
                       .union(matches.technically_forfeited)
                       .union(home_team_matches.bye)
    end

    def forfeit_lost_matches
      away_forfeit = away_team_matches.away_team_forfeited
      home_team_matches.home_team_forfeited.union(away_forfeit).union(matches.mutually_forfeited)
    end

    def won_rounds_against_tied_rosters
      rosters = tied_rosters.select(:id)
      won_rounds.joins(:match)
                .where('league_matches.home_team_id IN (?) OR league_matches.away_team_id IN (?)',
                       rosters, rosters)
    end

    def tied_rosters
      division.rosters.active.where(points: points).where.not(id: id)
    end

    def update_match_counters!
      # Keep old points for updating tied rosters
      old_points = points

      assign_updated_match_counters
      save!(validate: false)

      # Update tied counts on relevant rosters (from old and new points)
      update_tied_rosters_match_counters_tied!(old_points)
    end

    def update_tied_rosters_match_counters_tied!(old_points)
      division.rosters.active.where(points: old_points).find_each(&:update_match_counters_tied!)
      tied_rosters.find_each(&:update_match_counters_tied!)
      update_match_counters_tied!
    end

    def update_match_counters_tied!
      self.won_rounds_against_tied_rosters_count = won_rounds_against_tied_rosters.count

      save!(validate: false)
    end

    def rosters_not_played
      division.rosters.active
              .where.not(id: id)
              .where.not(id: home_team_matches.select(:away_team_id))
              .where.not(id: away_team_matches.select(:home_team_id))
    end

    def disband
      transaction do
        forfeit_all!
        transfer_requests.destroy_all
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

    def sort_keys
      @sort_keys ||= calculate_sort_keys
    end

    def schedule_data=(data)
      self[:schedule_data] = if league.scheduler
                               league.scheduler.transform_data(data)
                             end
    end

    private

    def assign_updated_match_counters
      # Requires multi-phase updating, as each change is dependent on the previous
      assign_attributes(total_scores:               calculate_total_scores,
                        won_rounds_count:           won_rounds.count,
                        drawn_rounds_count:         drawn_rounds.count,
                        lost_rounds_count:          lost_rounds.count,
                        forfeit_won_matches_count:  forfeit_won_matches.count,
                        forfeit_lost_matches_count: forfeit_lost_matches.count)

      self.points = calculate_points
      self.won_rounds_against_tied_rosters_count = won_rounds_against_tied_rosters.count
    end

    def calculate_sort_keys
      keys = [ranking || Float::INFINITY, disbanded? ? 1 : -points]

      tiebreaker_keys = league.tiebreakers.map { |tiebreaker| -tiebreaker.get_comparison(self) }

      keys + tiebreaker_keys
    end

    def calculate_points
      local_counts = [won_rounds_count, drawn_rounds_count, lost_rounds_count,
                      forfeit_won_matches_count, forfeit_lost_matches_count]
      comp_counts = league.point_multipliers

      local_counts.zip(comp_counts).map { |x, y| x * y }.sum
    end

    def calculate_total_scores
      not_forfeited_home_team_rounds.sum(:home_team_score) +
        not_forfeited_away_team_rounds.sum(:away_team_score)
    end

    def forfeit_all!
      no_forfeit = Match.forfeit_bies[:no_forfeit]

      home_team_matches.where(forfeit_by: no_forfeit).find_each do |match|
        match.update!(forfeit_by: Match.forfeit_bies[:home_team_forfeit])
      end
      away_team_matches.where(forfeit_by: no_forfeit).find_each do |match|
        match.update!(forfeit_by: Match.forfeit_bies[:away_team_forfeit])
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
