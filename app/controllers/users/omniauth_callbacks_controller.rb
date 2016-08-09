module Users
  class OmniauthCallbacksController < Devise::OmniauthCallbacksController
    # Don't need to protect against forgery for omniauth logins
    skip_before_action :verify_authenticity_token

    def steam
      auth = request.env['omniauth.auth']

      user = User.find_by(steam_id: auth.uid)

      if user
        sign_in_and_redirect user
      else
        session['devise.steam_data'] = auth.except('extra').except('info')
        redirect_to new_user_path(name: auth.info.nickname)
      end
    end

    def failure
      redirect_back(fallback_location: root_path)
    end
  end
end
