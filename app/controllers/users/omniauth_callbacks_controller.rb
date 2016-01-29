module Users
  class OmniauthCallbacksController < Devise::OmniauthCallbacksController
    # Don't need to protect against forgery for omniauth logins
    skip_before_action :verify_authenticity_token

    def steam
      auth = request.env['omniauth.auth']

      auth_session = auth.except('extra').except('info')
      session['devise.steam_data'] = auth_session

      user = User.find_by(steam_id: auth.uid)

      if user.nil?
        redirect_to new_user_path(name: auth.info.nickname)
      else
        sign_in_and_redirect user
      end
    end

    def failure
      redirect_to :back
    end
  end
end
