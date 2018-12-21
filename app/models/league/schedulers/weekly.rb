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

      def validate_roster(roster)
        availability = roster.schedule_data['availability']

        days_available = 0
        days.each_with_index do |day, index|
          name = Date::DAYNAMES[index]
          days_available += 1 if day && availability[name]
        end

        roster.errors.add(:schedule_data, 'Not enough availability') if days_available < minimum_selected
      end

      # Data validation for schedule_data on rosters
      def transform_data(data)
        data.select! { |key, _| %w[type availability].include?(key.to_s) }

        return unless data['type'] == 'weekly'

        availability = data['availability']
        return unless availability

        availability.each do |week, value|
          return nil unless schedule_days.include?(week)

          availability[week] = ['true', true].include? value
        end

        data
      end

      def default_schedule
        availability = Date::DAYNAMES.each_with_index.map { |name, i| { name => days[i] } }
                                     .reduce(&:merge)

        { 'type' => 'weekly', 'availability' => availability }
      end

      def schedule_days
        offset = self.class.start_of_weeks[start_of_week]
        rotated_names = Date::DAYNAMES.rotate(offset)
        rotated_days  = days.rotate(offset)

        rotated_names.each_with_index.select { |_, i| rotated_days[i] }.map(&:first)
      end

      def common_schedule(roster1, roster2)
        common = []

        schedule_days.each do |day|
          common << day if roster1.schedule_data['availability'].include?(day) &&
                           roster2.schedule_data['availability'].include?(day)
        end

        common
      end

      private

      def validate_days_length
        return if days.blank?

        errors.add(:days, 'Invalid length') unless days.length == 7
      end

      def validate_days_minimum
        return if days.blank? || minimum_selected.blank?

        unless minimum_selected.zero? || minimum_selected <= days.count(true)
          errors.add(:days, 'Must have more than the minimum required')
        end
      end

      def set_defaults
        self.start_of_week = 'Sunday' if start_of_week.blank?
      end
    end
  end
end
