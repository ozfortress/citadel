module Forums
  class Topic < ApplicationRecord
    has_ancestry cache_depth: true
    belongs_to :isolated_by, optional: true, class_name: 'Topic'

    belongs_to :created_by, class_name: 'User'

    has_many :threads,       dependent: :destroy
    has_many :subscriptions, dependent: :destroy

    validates :name, presence: true, length: { in: 1..128 }
    validates :locked,         inclusion: { in: [true, false] }
    validates :pinned,         inclusion: { in: [true, false] }
    validates :hidden,         inclusion: { in: [true, false] }
    validates :isolated,       inclusion: { in: [true, false] }
    validates :default_hidden, inclusion: { in: [true, false] }
    validates :default_locked, inclusion: { in: [true, false] }

    scope :locked,   -> { where(locked: true) }
    scope :unlocked, -> { where(locked: false) }
    scope :pinned,   -> { where(pinend: true) }
    scope :hidden,   -> { where(hidden: true) }
    scope :visible,  -> { where(hidden: false) }
    scope :isolated, -> { where(isolated: true) }

    after_initialize :set_defaults, unless: :persisted?

    before_save :update_isolated_by

    after_save :cascade_isolated_by!
    after_save :cascade_threads_depth!

    def not_isolated?
      isolated_by.nil?
    end

    private

    def set_defaults
      [:pinned, :isolated, :default_hidden].each do |attribute|
        self[attribute] = false if self[attribute].nil?
      end

      return unless parent
      self.locked = parent.locked if locked.nil?
      self.hidden = parent.hidden if hidden.nil?
    end

    def cascade_threads_depth!
      return unless saved_changes.key? 'ancestry'

      threads.update(depth: depth + 1)
    end

    def cascade_isolated_by!
      return if persisted? || !isolated_changed? || !children?

      descendants.where(isolated_by: isolated_by_was).update(isolated_by: self)
    end

    def update_isolated_by
      if isolated?
        self.isolated_by = self
      elsif persisted? || ancestry_changed?
        self.isolated_by = ancestors.where.not(isolated_by: nil).first
      end
    end
  end
end
