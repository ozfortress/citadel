require 'rails_helper'

describe Ahoy::Event do
  before(:all) { create(:ahoy_event) }

  it { should belong_to(:visit) }
  it { should allow_value(nil).for(:visit) }
end
