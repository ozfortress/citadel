Ahoy.geocode = false
Ahoy.track_visits_immediately = true

class Ahoy::Store < Ahoy::Stores::ActiveRecordTokenStore
  def api_key
    controller.try(:api_key)
  end

  def user
    controller.try(:current_user)
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
