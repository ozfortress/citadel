require 'rails_helper'

describe Forums::Post do
  before(:all) { create(:forums_post) }

  it { should belong_to(:thread).inverse_of(:posts).counter_cache(true) }
  it { should_not allow_value(nil).for(:thread) }

  it { should belong_to(:created_by).class_name('User') }
  it { should_not allow_value(nil).for(:created_by) }

  it { should validate_presence_of(:content) }
end
