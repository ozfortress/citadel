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
      analysis: {
        filter: {
          edgeNGram_filter: {
            type: :edgeNGram,
            min_gram: 2,
            max_gram: 20,
          },
        },
        tokenizer: {
          edgeNgram_tokenizer: {
            type: :edgeNGram,
            min_gram: 2,
            max_gram: 20,
            token_chars: [:letter, :digit],
          }
        },
        analyzer: {
          search: {
            tokenizer: :edgeNgram_tokenizer,
            filter: [:lowercase, :asciifolding, :edgeNGram_filter],
          }
        }
      }
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
      match = { query: query, fields: searchable_fields, type: :most_fields }
      search(query: { multi_match: match })
    end
  end
end
