require 'rails_helper'

describe Forums::Post do
  before(:all) { create(:forums_post) }

  it { should belong_to(:thread).inverse_of(:posts).counter_cache(true) }

  it { should belong_to(:created_by).class_name('User') }

  it { should validate_presence_of(:content) }
  it { should validate_length_of(:content).is_at_least(10).is_at_most(10_000) }
end
