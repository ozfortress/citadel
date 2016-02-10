module Meta
  class FormatsController < MetaController
    skip_before_action :require_any_admin_permissions, only: [:show]
    skip_before_action :require_meta, only: [:show]

    def index
    end

    def new
      @format = Format.new
    end

    def create
      @format = Format.new(format_params)

      if @format.save
        redirect_to meta_format_path(@format)
      else
        render :new
      end
    end

    def show
      @format = Format.find(params[:id])
    end

    def edit
      @format = Format.find(params[:id])
    end

    def update
      @format = Format.find(params[:id])

      if @format.update(format_params)
        redirect_to meta_format_path(@format)
      else
        render :edit
      end
    end

    # TODO: Delete

    private

    def format_params
      params.require(:format_).permit(:game_id, :player_count, :name, :description)
    end
  end
end
