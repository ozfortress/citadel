module Forums
  class Topic < ApplicationRecord
    has_ancestry cache_depth: true

    belongs_to :created_by, class_name: 'User'

    has_many :threads, dependent: :destroy

    validates :name, presence: true, length: { in: 1..128 }
    validates :locked,         inclusion: { in: [true, false] }
    validates :pinned,         inclusion: { in: [true, false] }
    validates :hidden,         inclusion: { in: [true, false] }
    validates :isolated,       inclusion: { in: [true, false] }
    validates :default_hidden, inclusion: { in: [true, false] }

    scope :locked,   -> { where(locked: true) }
    scope :unlocked, -> { where(locked: false) }
    scope :pinned,   -> { where(pinend: true) }
    scope :hidden,   -> { where(hidden: true) }
    scope :visible,  -> { where(hidden: false) }
    scope :isolated, -> { where(isolated: true) }

    after_save :cascade_threads_depth!, if: :ancestry_changed?

    after_initialize :set_defaults, unless: :persisted?

    def not_isolated?
      !isolated && (!parent || ancestors.empty? || ancestors.isolated.empty?)
    end

    private

    def set_defaults
      return unless parent
      self.locked = parent.locked if locked.nil?
      self.hidden = parent.hidden if hidden.nil?
    end

    def cascade_threads_depth!
      threads.update(depth: depth + 1)
    end
  end
end
