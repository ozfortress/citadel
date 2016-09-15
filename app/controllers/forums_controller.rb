class ForumsController < ApplicationController
  include Forums::Permissions

  def show
    @topics  = Forums::Topic.roots
    @threads = Forums::Thread.where(topic: nil)

    return if user_can_manage_forums?
    @topics  = @topics.visible
    @threads = @threads.visible
  end
end
