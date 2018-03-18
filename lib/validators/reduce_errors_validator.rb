# show only one error message per field
#
class ReduceErrorsValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, _value)
    errors = record.errors
    return until errors.messages.key? attribute

    error = errors[attribute]
    error.slice!(-1) until error.size <= 1
  end
end
