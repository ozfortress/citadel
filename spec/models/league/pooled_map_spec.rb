require 'rails_helper'

describe League::PooledMap do
  it { should belong_to(:league).inverse_of(:pooled_maps) }
  it { should belong_to(:map) }
end
