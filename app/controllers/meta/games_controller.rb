module Meta
  class GamesController < MetaController
    skip_before_action :require_any_admin_permissions, only: [:show]
    skip_before_action :require_meta, only: [:show]

    def index
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
      @game = Game.find(params[:id])
    end

    def edit
      @game = Game.find(params[:id])
    end

    def update
      @game = Game.find(params[:id])

      if @game.update(game_params)
        redirect_to meta_game_path(@game)
      else
        render :edit
      end
    end

    # TODO: Delete

    private

    def game_params
      params.require(:game).permit(:name)
    end
  end
end
