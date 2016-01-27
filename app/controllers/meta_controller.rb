class MetaController < ApplicationController
  before_action :require_meta

  def index
  end

  private

  def require_meta
    redirect_to :back unless user_signed_in? && current_user.can?(:edit, :games)
  end
end
