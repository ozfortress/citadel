module Forums
  module ThreadsCommon
    extend ActiveSupport::Concern

    def threads_show
      @page = params[:page]
      @posts = @thread.posts.includes(:created_by).paginate(page: @page)
      @post ||= Post.new
    end
  end
end
