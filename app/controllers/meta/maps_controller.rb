module Meta
  class MapsController < MetaController
    skip_before_action :require_any_admin_permissions, only: [:show]
    skip_before_action :require_meta, only: [:show]

    def index
    end

    def new
      @map = Map.new
    end

    def create
      @map = Map.new(map_params)

      if @map.save
        redirect_to meta_map_path(@map)
      else
        render :new
      end
    end

    def show
      @map = Map.find(params[:id])
    end

    def edit
      @map = Map.find(params[:id])
    end

    def update
      @map = Map.find(params[:id])

      if @map.update(map_params)
        redirect_to meta_map_path(@map)
      else
        render :edit
      end
    end

    # TODO: Delete

    private

    def map_params
      params.require(:map).permit(:game_id, :name, :description)
    end
  end
end
