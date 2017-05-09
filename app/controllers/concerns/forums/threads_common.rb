module Forums
  module ThreadsCommon
    extend ActiveSupport::Concern

    def threads_show
      @posts = @thread.posts.includes(:created_by).paginate(page: params[:page])
      @post ||= Post.new
    end
  end
end
