module Meta
  class GamesController < ApplicationController
    def index
    end

    def new
      @game = Game.new
    end

    def create
      @game = Game.new(game_params)

      if @game.save
        redirect_to meta_games_path
      else
        render :new
      end
    end

    def edit
    end

    def update
    end

    private

    def game_params
      params.require(:game).permit(:name)
    end
  end
end
