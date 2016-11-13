module Meta
  class MapsController < MetaController
    skip_before_action :require_any_admin_permissions, only: [:show]
    skip_before_action :require_meta, only: [:show]

    before_action except: [:index, :new, :create] { @map = Map.find(params[:id]) }

    def index
      @maps = Map.all
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
    end

    def edit
    end

    def update
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
