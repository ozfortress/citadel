class League
  class PooledMap < ApplicationRecord
    belongs_to :league, inverse_of: :pooled_maps
    belongs_to :map
  end
end
