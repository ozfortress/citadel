class TeamsController < ApplicationController
  include TeamPermissions

  before_action except: [:index, :new, :create] { @team = Team.find(params[:id]) }

  before_action :require_team_create_permission, only: [:new, :create]
  before_action :require_team_edit_permission, only: [:edit, :update, :recruit,
                                                      :invite, :kick, :destroy]
  before_action :require_login, only: :leave
  before_action :require_on_team, only: :leave

  def index
    @teams = Team.search(params[:q])
                 .paginate(page: params[:page])
                 .load
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

    teams_show_fetch_teams
    teams_show_fetch_users
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
    @users = User.search(params[:q])
                 .paginate(page: params[:page])
                 .load
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
    rosters.includes(:players, :transfers)
           .merge(League::Roster::Player.order(created_at: :asc))
           .merge(League::Roster::Transfer.order(created_at: :desc))
  end

  def matches_for(rosters)
    matches = rosters.matches
                     .order(round_number: :asc, created_at: :desc)
                     .includes(:rounds, :home_team, :away_team)

    matches.group_by do |match|
      if rosters.include?(match.home_team)
        match.home_team
      else
        match.away_team
      end
    end
  end

  def teams_show_fetch_teams
    @players               = @team.players
    @transfers             = @team.transfers

    @active_rosters        = roster_includes_for(@team.rosters.for_incomplete_league).load
    @active_roster_matches = matches_for @active_rosters

    @past_rosters          = roster_includes_for(@team.rosters.for_completed_league).load
    @past_roster_matches   = matches_for @past_rosters

    @upcoming_matches = @team.matches.pending.includes(:home_team, :away_team)
                             .order(created_at: :asc)
  end

  def teams_show_fetch_users
    rosters = @active_rosters + @past_rosters
    id_holders = @players + @transfers
    id_holders += (rosters.map(&:players) + rosters.map(&:transfers)).reduce([], :+)

    user_ids = id_holders.map(&:user_id).uniq

    @users = User.where(id: user_ids).index_by(&:id)
    prefetch_team_permissions(@users.values)
    id_holders.each { |h| h.user = @users[h.user_id] }
  end

  def prefetch_team_permissions(users)
    User.permissions(users).fetch(:edit, @team) unless users.empty?
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
