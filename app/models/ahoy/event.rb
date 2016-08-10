module Ahoy
  class Event < ActiveRecord::Base
    include Ahoy::Properties

    self.table_name = :ahoy_events

    default_scope { order(time: :desc) }

    belongs_to :visit
    belongs_to :user

    def self.search(query)
      return all if query.blank?

      where('ip = ? OR uri = ? OR method = ? OR ahoy_events.name = ? OR users.name = ?',
            query, query, query, query, query).joins(:user)
    end
  end
end
