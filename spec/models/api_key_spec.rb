require 'rails_helper'

describe APIKey do
  before(:all) { create(:api_key) }

  it { should validate_length_of(:name).is_at_most(64) }
  it { should allow_value('').for(:name) }

  it 'Should generate a 64 bit key on creation' do
    api_key = APIKey.create!

    expect(api_key.key).to_not be_blank
    expect(api_key.key.length).to eq(64)
  end
end
