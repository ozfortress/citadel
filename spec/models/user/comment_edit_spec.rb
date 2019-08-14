require 'rails_helper'

describe User::CommentEdit do
  before(:all) { create(:user_comment_edit) }

  it { should belong_to(:comment).class_name('User::Comment') }

  it { should belong_to(:created_by) }

  it { should validate_presence_of(:content) }
end
