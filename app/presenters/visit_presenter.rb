class VisitPresenter < BasePresenter
  presents :visit

  def user
    @user = present(visit.user)
  end

  def started_at
    visit.started_at.strftime('%c')
  end
end
