require 'rails_helper'

describe 'application/notifications-ajax' do
  before do
    @notifications = []
    @notifications << build_stubbed(:user_notification, read: false)
    @notifications << build_stubbed(:user_notification, read: true)
  end

  it 'displays' do
    assign(:notifications, @notifications)

    render
  end
end
