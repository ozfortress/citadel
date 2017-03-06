require 'rails_helper'

describe Visit do
  before(:all) { create(:visit) }

  it { should belong_to(:user) }
  it { should allow_value(nil).for(:user) }

  it { should belong_to(:api_key) }
  it { should allow_value(nil).for(:api_key) }

  it { should have_many(:events).class_name('Ahoy::Event') }
end
