require 'rails_helper'

describe User::Notification do
  before(:all) { create(:user_notification) }

  it { should belong_to(:user) }
  it { should_not allow_value(nil).for(:user) }

  it { should validate_presence_of(:message) }

  it { should validate_presence_of(:link) }
end
