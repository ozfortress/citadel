class ForumsController < ApplicationController
  def show
    @topics  = Forums::Topic.roots
    @threads = Forums::Thread.where(topic: nil)
  end
end
