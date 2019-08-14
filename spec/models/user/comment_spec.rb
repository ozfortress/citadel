require 'rails_helper'

describe User::Comment do
  before(:all) { create(:user_comment) }

  it { should belong_to(:user) }

  it { should belong_to(:created_by).class_name('User') }

  it { should validate_presence_of(:content) }
end
