require 'rails_helper'
require 'support/shoulda'
require 'support/factory_girl'

describe Forum::Topic do
  before { create(:forum_topic) }

  it { should belong_to(:parent_topic).class_name('Forum::Topic') }
  it { should allow_value(nil).for(:parent_topic) }

  it { should belong_to(:created_by).class_name('User') }
  it { should_not allow_value(nil).for(:created_by) }

  it { should validate_presence_of(:name) }
  it { should validate_length_of(:name).is_at_least(1) }
  it { should validate_length_of(:name).is_at_most(128) }
end
