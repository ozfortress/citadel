module Search
  module_function

  def transform_query(query)
    I18n.transliterate(query.strip).downcase
  end
end
