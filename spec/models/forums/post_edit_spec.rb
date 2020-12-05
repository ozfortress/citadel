require 'rails_helper'

describe Forums::PostEdit do
  before(:all) { create(:forums_post_edit) }

  it { should belong_to(:post).inverse_of(:edits).counter_cache(:edits_count) }

  it { should belong_to(:created_by).class_name('User') }

  it { should validate_presence_of(:content) }
  it { should validate_length_of(:content).is_at_least(10).is_at_most(50_000) }
end
