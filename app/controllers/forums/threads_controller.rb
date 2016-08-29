module Forums
  class ThreadsController < ApplicationController
    def show
      @thread = Forums::Thread.find(params[:id])
      @posts = @thread.posts
    end
  end
end
