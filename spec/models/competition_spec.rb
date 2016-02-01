require 'rails_helper'

describe Competition do
  before { create(:competition) }

  it { should belong_to(:format) }
  it { should have_many(:divisions) }

  it { should validate_presence_of(:name) }
  it { should validate_length_of(:name).is_at_least(1) }
  it { should validate_length_of(:name).is_at_most(64) }

  it { should validate_presence_of(:description) }
end
