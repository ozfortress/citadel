module Searchable
  extend ActiveSupport::Concern

  class_methods do
    def search_all(param)
      if param.blank?
        all
      else
        simple_search(param).records
      end
    end
  end
end
