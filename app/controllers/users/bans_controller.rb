module Users
  class BansController < ApplicationController
    include ::UsersPermissions

    before_action { @user = User.find(params[:user_id]) }

    before_action except: :index do
      @action = params.require(:action_).to_sym
      @subject = params.require(:subject).to_sym
      @model = User.ban_model_for(@action, @subject)
    end

    before_action :require_user_permissions

    def index
      @ban_models = User.ban_models.map do |_action, bans|
        bans.map do |subject, model|
          next if model.subject? || !current_user.can?(:edit, subject)

          model
        end
      end.reduce(:+).compact.sort_by(&:association_name)

      @bans = @ban_models.map { |model| model.where(user: @user).to_a }.reduce(:+).sort_by(&:created_at)

      @new_bans = @ban_models.map(&:new)
    end

    def create
      @ban = @model.new(ban_params.merge(user: @user))

      if @ban.save
        redirect_to user_bans_path(@user)
      else
        index
        @new_bans.map! { |ban| ban.class == @model ? @ban : ban }
        render :index
      end
    end

    def destroy
      @ban = @model.find(params[:id])
      @ban.destroy!

      redirect_to user_bans_path(@user)
    end

    private

    def ban_params
      params.require(:ban).permit(:reason, :terminated_at)
    end

    def require_user_permissions
      redirect_back(fallback_location: user_path(@user)) unless user_can_edit_users?
    end
  end
end
