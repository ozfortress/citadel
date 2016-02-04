class CompetitionRoster < ActiveRecord::Base
  include Roster

  belongs_to :team
  belongs_to :division
  has_many :transfers, class_name: 'CompetitionTransfer'

  validates :team, presence: true
  validates :division, presence: true
  validates :points, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :approved, inclusion: { in: [true, false] }

  after_initialize :set_defaults

  private

  def set_defaults
    self.points   = 0     if points.nil?
    self.approved = false if approved.nil?
  end
end
