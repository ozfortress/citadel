class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def steam
    auth = request.env["omniauth.auth"]

    session["devise.steam_data"] = request.env["omniauth.auth"]

    user = User.find_by(:steam_id => auth.uid)

    if user.nil?
      redirect_to users_new_url
    else
      sign_in_and_redirect user
    end
  end

  def failure
    redirect_to root_path
  end
end
