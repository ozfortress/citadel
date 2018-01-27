# Be sure to restart your server when you modify this file.
#
# This file contains migration options to ease your Rails 5.0 upgrade.
#
# Once upgraded flip defaults one by one to migrate to the new default.
#
# Read the Rails 5.0 release notes for more info on each option.

# Enable per-form CSRF tokens. Previous versions had false.
Rails.application.config.action_controller.per_form_csrf_tokens = true

# Enable origin-checking CSRF mitigation. Previous versions had false.
Rails.application.config.action_controller.forgery_protection_origin_check = true

# Make Ruby 2.4 preserve the timezone of the receiver when calling `to_time`.
# Previous versions had false.
ActiveSupport.to_time_preserves_timezone = false

# Require `belongs_to` associations by default. Previous versions had false.
ActiveRecord::Base.belongs_to_required_by_default = true

# Rails is changing some things which throw deprecation warnings in dependencies
# TODO: Remove this when dependencies update
silenced = [
  /The behavior of `changed` inside of after callbacks will be changing in the next version of Rails/,
  /The behavior of `changed_attributes` inside of after callbacks will be changing in the next version of Rails/,
] # list of warnings you want to silence

silenced_expr = Regexp.new(silenced.join('|'))

ActiveSupport::Deprecation.behavior = lambda do |msg, stack|
  unless msg =~ silenced_expr
    ActiveSupport::Deprecation::DEFAULT_BEHAVIORS[:stderr].call(msg, stack)
  end
end
