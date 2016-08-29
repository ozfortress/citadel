class ForumsController < ApplicationController
  def show
    @topics  = Forums::Topic.where(parent_topic: nil)
    @threads = Forums::Thread.where(topic: nil)
  end
end
