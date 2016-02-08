module Meta
  class FormatsController < MetaController
    def index
    end

    def new
      @format = Format.new
    end

    def create
      p params
      @format = Format.new(format_params)

      if @format.save
        redirect_to meta_formats_path
      else
        render :new
      end
    end

    def edit
    end

    def update
    end

    private

    def format_params
      params.require(:format_).permit(:game_id, :player_count, :name, :description)
    end
  end
end
