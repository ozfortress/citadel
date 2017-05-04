class TeamsController < ApplicationController
  include TeamPermissions

  before_action except: [:index, :new, :create] { @team = Team.find(params[:id]) }

  before_action :require_team_create_permission, only: [:new, :create]
  before_action :require_team_edit_permission, only: [:edit, :update, :recruit,
                                                      :invite, :kick, :destroy]
  before_action :require_login, only: :leave
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

    teams_show_includes
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
    rosters.includes(:players, users: User.admin_associations,
                               transfers: { user: User.admin_associations })
           .merge(League::Roster::Player.order(created_at: :asc))
           .merge(League::Roster::Transfer.order(created_at: :desc))
  end

  def match_includes_for(matches)
    matches.order(round_number: :asc, created_at: :desc)
           .includes(:rounds, :home_team, :away_team)
  end

  def teams_show_includes
    @players               = @team.players.includes(user: User.admin_associations)
    @transfers             = @team.transfers.includes(user: User.admin_associations)

    @active_rosters        = roster_includes_for @team.rosters.for_incomplete_league
    @active_roster_matches = @active_rosters.map { |r| match_includes_for r.matches }

    @past_rosters          = roster_includes_for @team.rosters.for_completed_league
    @past_roster_matches   = @past_rosters.map { |r| match_includes_for r.matches }

    @upcoming_matches = @team.matches.pending.includes(:home_team, :away_team)
                             .order(created_at: :asc)
  end

  def team_params
    params.require(:team).permit(:name, :avatar, :remove_avatar, :description)
  end

  def require_team_create_permission
    redirect_to teams_path unless user_can_create_team?
  end

  def require_team_edit_permission
    redirect_to team_path(@team) unless user_can_edit_team?
  end

  def require_on_team
    redirect_to team_path(@team) unless @team.on_roster?(current_user)
  end
end
