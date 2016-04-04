require 'rails_helper'
require 'support/shoulda'
require 'support/factory_girl'

describe UserNameChange do
  let!(:user) { create(:user) }

  it { should belong_to(:user) }
  it { should belong_to(:approved_by).class_name('User') }
  it { should belong_to(:denied_by).class_name('User') }

  it { should validate_presence_of(:user) }

  it { should validate_presence_of(:name) }
  it { should validate_length_of(:name).is_at_least(1) }
  it { should validate_length_of(:name).is_at_most(64) }
end
