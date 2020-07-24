module Meta
  class GamesController < MetaController
    skip_before_action :require_any_admin_permissions, only: [:show]
    skip_before_action :require_meta, only: [:show]

    before_action(except: [:index, :new, :create]) { @game = Game.find(params[:id]) }

    def index
      @games = Game.all
    end

    def new
      @game = Game.new
    end

    def create
      @game = Game.new(game_params)

      if @game.save
        redirect_to meta_game_path(@game)
      else
        render :new
      end
    end

    def show
    end

    def edit
    end

    def update
      if @game.update(game_params)
        redirect_to meta_game_path(@game)
      else
        render :edit
      end
    end

    def destroy
      if @game.destroy
        redirect_to meta_games_path
      else
        render :edit
      end
    end

    private

    def game_params
      params.require(:game).permit(:name)
    end
  end
end
