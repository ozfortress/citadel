class CompetitionRoster < ActiveRecord::Base
  include Roster

  belongs_to :team
  belongs_to :division
  delegate :competition, to: :division, allow_nil: true
  has_many :transfers, inverse_of: :roster, class_name: 'CompetitionTransfer'
  accepts_nested_attributes_for :transfers

  validates :team,        presence: true, uniqueness: { scope: :division_id }
  validates :division,    presence: true
  validates :name,        presence: true, uniqueness: { scope: :division_id },
                          length: { in: 1..64 }
  validates :description, presence: true, allow_blank: true
  validates :points,      presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :approved,    inclusion: { in: [true, false] }

  after_initialize :set_defaults

  private

  def set_defaults
    self.points   = 0     if points.nil?
    self.approved = false if approved.nil?
  end
end
