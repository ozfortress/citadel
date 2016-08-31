# Ruby 3 defaults this on
# frozen_string_literal: true

module Forums
  PATH_SEP = ' / '.freeze

  def self.table_name_prefix
    'forum_'
  end
end
