Ahoy.geocode = false
Ahoy.track_visits_immediately = true

class Ahoy::Store < Ahoy::Stores::ActiveRecordTokenStore
  def api_key
    controller.api_key if controller.respond_to?(:api_key)
  end

  def user
    controller.current_user if controller.respond_to?(:current_user)
  end

  def exclude?
    !api_key && bot?
  end

  def track_visit(options)
    super do |visit|
      visit.api_key = api_key
      visit.user    = user
    end
  end
end
