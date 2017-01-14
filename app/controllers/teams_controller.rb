class TeamsController < ApplicationController
  include TeamPermissions

  before_action except: [:index, :new, :create] { @team = Team.find(params[:id]) }

  before_action :require_login, only: [:new, :create, :leave]
  before_action :require_team_permission, except: [:index, :new, :create, :show, :leave]
  before_action :require_on_team, only: :leave

  def index
    @teams = Team.search(params[:q]).paginate(page: params[:page])
  end

  def new
    @team = Team.new
  end

  def create
    @team = Teams::CreationService.call(current_user, team_params)

    if @team.persisted?
      redirect_to team_path(@team)
    else
      render :new
    end
  end

  def show
    @invite = @team.invite_for(current_user) if user_signed_in?

    @players        = @team.players.includes(:user)
    @transfers      = @team.transfers.includes(:user)
    @active_rosters = roster_includes_for @team.rosters.for_incomplete_league
    @past_rosters   = roster_includes_for @team.rosters.for_completed_league

    @matches        = @team.matches.pending.includes(:home_team, :away_team)
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
    @users = User.search(params[:q]).paginate(page: params[:page])
  end

  def invite
    user = User.find(params[:user_id])
    Teams::InvitationService.call(@team, user) unless @team.invited?(user) || @team.on_roster?(user)

    redirect_to team_path(@team)
  end

  def leave
    Teams::LeavingService.call(current_user, @team)

    redirect_back(fallback_location: team_path(@team))
  end

  def kick
    @user = User.find(params[:user_id])
    Teams::KickingService.call(@user, @team)

    redirect_back(fallback_location: team_path(@team))
  end

  def destroy
    if @team.destroy
      redirect_to teams_path
    else
      render :edit
    end
  end

  private

  def roster_includes_for(rosters)
    rosters.includes(:players, :users, transfers: :user)
           .order('league_roster_players.created_at')
           .order('league_roster_transfers.created_at DESC')
  end

  def team_params
    params.require(:team).permit(:name, :avatar, :remove_avatar, :description)
  end

  def require_team_permission
    redirect_to team_path(@team) unless user_can_edit_team?
  end

  def require_on_team
    redirect_to team_path(@team) unless @team.on_roster?(current_user)
  end
end
