class LeaguesController < ApplicationController
  include LeaguePermissions

  before_action except: [:index, :new, :create] do
    @league = League.find(params[:id])
  end

  before_action :require_user_leagues_permission, only: [:new, :create, :destroy]
  before_action :require_user_league_permission, only: [:edit, :update, :modify, :transfers]
  before_action :require_league_not_hidden_or_permission, only: [:show]
  before_action :require_hidden, only: [:destroy]

  def index
    @leagues = League.search_all(params[:q])
                     .order(status: :asc, created_at: :desc)
                     .paginate(page: params[:page])
  end

  def new
    @league = League.new
    @league.divisions.new
    @weekly_scheduler = @league.build_weekly_scheduler
  end

  def create
    @league = League.new(league_params)

    if @league.save
      redirect_to league_path(@league)
    else
      edit
      render :new
    end
  end

  def show
    @rosters = @league.rosters.includes(division: :league)
    @divisions = @league.divisions.includes(:approved_rosters)
    @roster = @league.roster_for(current_user) if user_signed_in?
    @matches = if @roster
                 @roster.matches
               else
                 @divisions.first.matches
               end.pending.includes(:home_team, :away_team)
  end

  def edit
    @weekly_scheduler = @league.weekly_scheduler || League::Schedulers::Weekly.new
  end

  def update
    if @league.update(league_params)
      redirect_to league_path(@league)
    else
      edit
      render :edit
    end
  end

  def modify
    if @league.update(status: params.require(:status))
      redirect_to league_path(@league)
    else
      render :edit
    end
  end

  def destroy
    if @league.destroy
      redirect_to admin_path(@league)
    else
      render :edit
    end
  end

  private

  def league_params
    params.require(:league).permit(
      :name, :description, :format_id, :signuppable, :roster_locked, :matches_submittable,
      :transfers_require_approval, :allow_round_draws, :allow_disbanding, :min_players,
      :max_players, :points_per_round_won, :points_per_round_drawn, :points_per_round_lost,
      :points_per_match_forfeit_loss, :points_per_match_forfeit_win, :schedule_locked, :schedule,
      weekly_scheduler_attributes: [:id, :start_of_week, :minimum_selected, days_indecies: []],
      tiebreakers_attributes: [:id, :kind, :_destroy],
      divisions_attributes: [:id, :name, :_destroy])
  end

  def require_hidden
    redirect_to league_path(@league) unless @league.hidden?
  end

  def require_user_leagues_permission
    redirect_to leagues_path unless user_can_edit_leagues?
  end

  def require_user_league_permission
    redirect_to league_path(@league) unless user_can_edit_league?
  end

  def require_league_not_hidden_or_permission
    redirect_to leagues_path unless !@league.hidden? || user_can_edit_league?
  end
end
