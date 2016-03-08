require 'rails_helper'

describe Division do
  before { create(:division) }

  it { should belong_to(:competition) }

  it { should validate_presence_of(:competition) }

  it { should validate_presence_of(:name) }
  it { should validate_length_of(:name).is_at_least(1) }
  it { should validate_length_of(:name).is_at_most(64) }
end
