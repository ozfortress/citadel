module Searchable
  extend ActiveSupport::Concern

  included do
    include Elasticsearch::Model
    include Elasticsearch::Model::Callbacks
  end

  GLOBAL_INDEX_SETTINGS = {
    index: {
      number_of_shards: 1,
      number_of_replicas: 0,
    }
  }.freeze

  def as_indexed_json(_ = {})
    out = {}

    self.class.searchable_fields.each do |field|
      out[field.to_s] = send(field)
    end

    out
  end

  class_methods do
    def searchable_fields(*fields)
      @searchable_fields ||= fields
    end

    def search_mappings(options = {}, &block)
      settings GLOBAL_INDEX_SETTINGS.merge(options) do
        mappings(dynamic: 'false', &block)
      end
    end

    def search_all(param)
      if param.blank?
        all
      else
        simple_search(param).records
      end
    end

    def simple_search(query)
      matches = []
      matches += simple_match_queries(query)
      matches << multi_match_query(query)
      search(query: { bool: { should: matches } })
    end

    private

    def simple_match_queries(query)
      searchable_fields.map do |field|
        { match: { field => query } }
      end
    end

    def multi_match_query(query)
      { multi_match: { query: query, fields: searchable_fields, type: :most_fields } }
    end
  end
end
