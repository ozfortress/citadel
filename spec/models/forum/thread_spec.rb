require 'rails_helper'
require 'support/shoulda'
require 'support/factory_girl'

describe Forum::Thread do
  before { create(:forum_thread) }

  it { should belong_to(:topic) }
  it { should_not allow_value(nil).for(:topic) }

  it { should belong_to(:created_by).class_name('User') }
  it { should_not allow_value(nil).for(:created_by) }

  it { should validate_presence_of(:title) }
  it { should validate_length_of(:title).is_at_least(1) }
  it { should validate_length_of(:title).is_at_most(128) }
end
