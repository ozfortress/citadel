module Users
  class OmniauthCallbacksController < Devise::OmniauthCallbacksController
    include UsersPermissions

    before_action :require_login, only: [:discord]

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

    def discord
      auth = request.env['omniauth.auth']
      discord_id = auth.extra.raw_info['id']
      discord_revoke_token(auth.credentials.token)
      link_discord(discord_id)
    end

    def failure
      redirect_back_or_to(root_path)
    end

    private

    def link_discord(discord_id)
      if current_user.update(discord_id:)
        flash[:notice] = 'Discord account linked!'
      else
        flash[:error] = 'This Discord account is already linked to another account.'
      end
      redirect_to edit_user_path(current_user)
    end

    def discord_revoke_token(token)
      uri = URI.parse("https://discord.com/api/oauth2/token/revoke?token=#{token}")
      http = Net::HTTP.new(uri.host, uri.port)
      post = Net::HTTP::Post.new(uri.to_s)
      http.request(post)
    end
  end
end
