module Forums
  class Subscription < ApplicationRecord
    belongs_to :user
    belongs_to :topic,  optional: true
    belongs_to :thread, optional: true

    validate :validates_either_topic_or_thread

    private

    def validates_either_topic_or_thread
      errors.add(:topic, 'is missing') if topic.blank? && thread.blank?
    end
  end
end
