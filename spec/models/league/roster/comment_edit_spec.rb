require 'rails_helper'

describe League::Roster::CommentEdit do
  before(:all) { create(:league_roster_comment_edit) }

  it { should belong_to(:created_by) }
  it { should_not allow_value(nil).for(:created_by) }

  it { should belong_to(:comment).class_name('League::Roster::Comment') }
  it { should_not allow_value(nil).for(:comment) }

  it { should validate_presence_of(:content) }
end
