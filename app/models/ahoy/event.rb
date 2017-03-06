module Ahoy
  class Event < ActiveRecord::Base
    include CountEstimator
    include Ahoy::Properties

    self.table_name = :ahoy_events

    belongs_to :visit, optional: true

    default_scope { order(time: :desc) }

    # Workaround for Ahoy bug
    def user=(value)
    end

    def self.search(query)
      return all if query.blank?

      where('visits.ip = ? OR ahoy_events.name = ? OR users.name = ? OR api_keys.name = ?',
            query, query, query, query)
        .includes(visit: [:user, :api_key])
        .references(visit: [:user, :api_key])
    end
  end
end
