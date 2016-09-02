require 'rails_helper'

describe 'permissions/index' do
  let(:user) { create(:user) }

  before do
    user.grant(:edit, :permissions)
  end

  it 'displays' do
    sign_in user
    assign(:permissions, User.permissions)

    render
  end
end
