require 'rails_helper'

describe Forums::PostEdit do
  before(:all) { create(:forums_post_edit) }

  it { should belong_to(:post) }
  it { should_not allow_value(nil).for(:post) }

  it { should belong_to(:created_by).class_name('User') }
  it { should_not allow_value(nil).for(:created_by) }

  it { should validate_presence_of(:content) }
end
