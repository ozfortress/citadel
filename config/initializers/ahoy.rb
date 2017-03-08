Ahoy.geocode = false
Ahoy.track_visits_immediately = true

class Ahoy::Store < Ahoy::Stores::ActiveRecordTokenStore
  def exclude?
    false
  end

  def track_visit(options)
    super do |visit|
      visit.api_key = controller.api_key      if controller.respond_to?(:api_key)
      visit.user    = controller.current_user if controller.respond_to?(:current_user)
    end
  end
end
