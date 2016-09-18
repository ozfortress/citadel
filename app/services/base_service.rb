module BaseService
  extend ActiveSupport::Concern

  included do
    include Rails.application.routes.url_helpers

    extend self
  end

  class_methods do
    def default_url_options
      {}
    end

    def rollback!
      fail ActiveRecord::Rollback
    end
  end
end
