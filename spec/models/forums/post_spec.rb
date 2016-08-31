require 'rails_helper'
require 'support/shoulda'
require 'support/factory_girl'

describe Forums::Post do
  before { create(:forums_post) }

  it { should belong_to(:thread) }
  it { should_not allow_value(nil).for(:thread) }

  it { should belong_to(:created_by).class_name('User') }
  it { should_not allow_value(nil).for(:created_by) }

  it { should validate_presence_of(:content) }
end
