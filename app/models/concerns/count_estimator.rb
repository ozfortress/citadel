module CountEstimator
  extend ActiveSupport::Concern

  class_methods do
    # Badly implemented count estimation for postgres
    # Useful when being off by >50 records is not a problem
    def count_estimate
      result = connection.execute("
        SELECT (reltuples/GREATEST(relpages, 1)) * (
          pg_relation_size('#{table_name}') /
          GREATEST(current_setting('block_size')::integer, 1)
        ) AS count
        FROM pg_class WHERE relname = '#{table_name}'")

      result[0]['count']
    end
  end
end
