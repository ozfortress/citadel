class TeamsController < ApplicationController
  include Searchable
  include TeamPermissions

  before_action except: [:index, :new, :create] { @team = Team.find(params[:id]) }

  before_action :require_login, only: [:new, :create, :leave]
  before_action :require_team_permission, except: [:index, :new, :create, :show, :leave]

  def index
    @teams = Team.search_all(params[:q]).paginate(page: params[:page])
  end

  def new
    @team = Team.new
  end

  def create
    @team = Team.new(team_params)

    if @team.save
      @team.add_player!(current_user)
      current_user.grant(:edit, @team)
      redirect_to team_path(@team)
    else
      render :new
    end
  end

  def show
  end

  def edit
  end

  def update
    if @team.update(team_params)
      redirect_to team_path(@team)
    else
      render :edit
    end
  end

  def recruit
    @users = User.search_all(params[:q]).paginate(page: params[:page])
  end

  def invite
    user = User.find(params[:user_id])

    @team.invite(user) unless @team.invited?(user) || @team.on_roster?(user)
    redirect_to team_path(@team)
  end

  def leave
    if params.key? :user_id
      require_team_permission
      user = User.find(params[:user_id])
    else
      user = current_user
    end

    @team.remove_player!(user) if @team.on_roster?(user)
    redirect_back(fallback_location: teams_path)
  end

  def destroy
    if @team.destroy
      redirect_to teams_path
    else
      render :edit
    end
  end

  private

  def team_params
    params.require(:team).permit(:name, :avatar, :description)
  end

  def require_team_permission
    redirect_to team_path(@team) unless user_can_edit_team?
  end
end
