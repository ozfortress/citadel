module Users
  class OmniauthCallbacksController < Devise::OmniauthCallbacksController
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
      redirect_to root_path
    end
  end
end
