require 'rails_helper'
require 'support/shoulda'
require 'support/factory_girl'

describe UserNameChange do
  let!(:name) { create(:user_name_change) }

  it { should belong_to(:user) }
  it { should belong_to(:approved_by).class_name('User') }
  it { should belong_to(:denied_by).class_name('User') }

  it { should validate_presence_of(:user) }

  it { should validate_presence_of(:name) }
  it { should validate_length_of(:name).is_at_least(1) }
  it { should validate_length_of(:name).is_at_most(64) }

  it 'notifies user on acceptance' do
    name.update!(approved_by: name.user)

    expect(name.user.notifications).to_not be_empty
  end

  it 'verifies name is unique' do
    user = build(:user)

    expect(build(:user_name_change, user: user, name: 'A')).to be_valid
    expect(build(:user_name_change, user: user, name: user.name)).to be_invalid
  end

  it 'only allows one request per user' do
    user = create(:user)
    create(:user_name_change, user: user)

    expect(build(:user_name_change, user: user)).to be_invalid
  end

  it 'verifies name is not already used by user' do
    user1 = create(:user)
    user2 = create(:user)

    expect(build(:user_name_change, user: user1, name: user2.name)).to be_invalid
  end

  it 'verifies name is not already used by another name change' do
    user1 = create(:user)
    user2 = create(:user)
    create(:user_name_change, user: user2, name: 'A')

    expect(build(:user_name_change, user: user1, name: 'A')).to be_invalid
  end
end
