class Ahoy::Store < Ahoy::Stores::ActiveRecordTokenStore
  def track_event(name, properties, options)
    super do |event|
      event.method = request.request_method
      event.ip     = request.remote_ip
      event.uri    = request.fullpath
    end
  end
end
