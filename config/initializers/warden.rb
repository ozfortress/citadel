# Called on login
Warden::Manager.after_set_user except: :fetch do |user, auth, opts|
  ip = auth.request.remote_ip

  # Track logins
  User::Log.log_user!(user, ip)

  # Keep track of the ip in the session so we can detect address changes
  auth.session[:ip] = ip
end
