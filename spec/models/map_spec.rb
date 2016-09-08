require 'rails_helper'

describe Map do
  before(:all) { create(:map) }

  it { should belong_to(:game) }
  it { should_not allow_value(nil).for(:game) }

  it { should validate_presence_of(:name) }
  it { should validate_uniqueness_of(:name) }
  it { should validate_length_of(:name).is_at_least(1) }
  it { should validate_length_of(:name).is_at_most(64) }

  it { should allow_value('').for(:description) }
  it { should validate_length_of(:description).is_at_least(0) }
end
