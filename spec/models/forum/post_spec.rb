require 'rails_helper'
require 'support/shoulda'
require 'support/factory_girl'

describe Forum::Post do
  before { create(:forum_post) }

  it { should belong_to(:thread) }
  it { should validate_presence_of(:thread) }

  it { should belong_to(:created_by).class_name('User') }
  it { should validate_presence_of(:created_by) }

  it { should validate_presence_of(:content) }
end
