class League
  module Schedulers
    class Weekly < ApplicationRecord
      belongs_to :league

      enum start_of_week: Date::DAYNAMES

      validates :minimum_selected, presence: true, numericality: { greater_than_or_equal_to: 0 }
      validates :days,             presence: true

      validate :validate_days_length
      validate :validate_days_minimum

      after_initialize :set_defaults

      # Custom attribute writer for #days
      def days_indecies=(values)
        array = Array.new(7, false)

        values.each do |index|
          array[index.to_i] = true
        end

        self[:days] = array
      end

      private

      def validate_days_length
        return unless days.present?

        errors.add(:days, 'invalid length') unless days.length == 7
      end

      def validate_days_minimum
        return unless days.present? && minimum_selected.present?

        unless minimum_selected == 0 || minimum_selected <= days.count(true)
          errors.add(:days, 'must have more than the minimum required')
        end
      end

      def set_defaults
        self.start_of_week = 'Sunday' unless start_of_week.present?
      end
    end
  end
end
