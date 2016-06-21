class LeaguesController < ApplicationController
  include LeaguePermissions

  before_action except: [:index, :new, :create] do
    @competition = Competition.find(params[:id])
  end

  before_action :require_user_leagues_permission, only: [:new, :create, :destroy]
  before_action :require_user_league_permission, only: [:edit, :update, :status, :transfers]
  before_action :require_league_not_hidden_or_permission, only: [:show]
  before_action :require_hidden, only: [:destroy]

  def index
    @competitions = Competition.search_all(params[:q])
                               .order(status: :asc, created_at: :desc)
                               .paginate(page: params[:page])
  end

  def new
    @competition = Competition.new
    @competition.divisions.new
  end

  def create
    @competition = Competition.new(league_params)

    if @competition.save
      redirect_to league_path(@competition)
    else
      render :new
    end
  end

  def show
  end

  def edit
  end

  def update
    if @competition.update(league_params)
      redirect_to league_path(@competition)
    else
      render :edit
    end
  end

  def status
    if @competition.update(status: params.require(:status))
      redirect_to league_path(@competition)
    else
      render :edit
    end
  end

  def destroy
    if @competition.destroy
      redirect_to admin_path(@competition)
    else
      render :edit
    end
  end

  private

  def league_params
    params.require(:competition).permit(:name, :description, :format_id, :signuppable,
                                        :roster_locked, :matches_submittable,
                                        :transfers_require_approval, :allow_set_draws,
                                        :allow_disbanding, :min_players, :max_players,
                                        :points_per_set_won, :points_per_set_drawn,
                                        :points_per_set_lost, :points_per_match_forfeit_loss,
                                        :points_per_match_forfeit_win,
                                        tiebreakers_attributes: [:id, :kind, :_destroy],
                                        divisions_attributes: [:id, :name, :_destroy])
  end

  def require_hidden
    redirect_to league_path(@competition) unless @competition.hidden?
  end

  def require_user_leagues_permission
    redirect_to leagues_path unless user_can_edit_leagues?
  end

  def require_user_league_permission
    redirect_to league_path(@competition) unless user_can_edit_league?
  end

  def require_league_not_hidden_or_permission
    redirect_to leagues_path unless !@competition.hidden? || user_can_edit_league?
  end
end
