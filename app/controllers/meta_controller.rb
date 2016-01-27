class MetaController < ApplicationController
  before_action :require_meta

  def index
  end

  private

  def require_meta
    unless user_signed_in? && current_user.can?(:edit, :games)
      redirect_to :back
    end
  end
end
