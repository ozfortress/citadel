require 'rails_helper'
require 'support/shoulda'
require 'support/factory_girl'
require 'auth/spec'

describe User do
  before { create(:user) }

  it { should validate_presence_of(:name) }
  it { should validate_uniqueness_of(:name) }
  it { should validate_length_of(:name).is_at_least(1) }
  it { should validate_length_of(:name).is_at_most(64) }

  it { should validate_presence_of(:steam_id) }
  it { should validate_uniqueness_of(:steam_id) }
  it { should validate_numericality_of(:steam_id).is_greater_than(0) }

  describe 'Permissions' do
    pending 'implement matcher'

    it { should validate_permission_to(:edit, :team) }
    it { should validate_permission_to(:edit, :teams) }
  end
end
