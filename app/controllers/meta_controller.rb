class MetaController < AdminController
  before_action :require_meta

  private

  def require_meta
    redirect_to root_path unless user_can_meta?
  end
end
