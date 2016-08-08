require 'rails_helper'
require 'support/shoulda'
require 'support/factory_girl'

describe User::Notification do
  let!(:notification) { create(:user_notification) }

  it { should belong_to(:user) }

  it { should validate_presence_of(:user) }

  it { should validate_presence_of(:message) }
  it { should validate_length_of(:message).is_at_least(1) }
  it { should validate_length_of(:message).is_at_most(128) }

  it { should validate_presence_of(:link) }
  it { should validate_length_of(:link).is_at_least(1) }
  it { should validate_length_of(:link).is_at_most(128) }
end
