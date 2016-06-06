# show only one error message per field
#
class ReduceValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, _)
    errors = record.errors
    return until errors.messages.key? attribute

    error = errors[attribute]
    error.slice!(-1) until error.size <= 1
  end
end
