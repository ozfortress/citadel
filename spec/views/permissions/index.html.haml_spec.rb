require 'rails_helper'

describe 'permissions/index' do
  let(:user) { build(:user) }

  before do
    allow(user).to receive(:can?).and_return(true)
  end

  it 'displays' do
    allow(view).to receive(:current_user).and_return(user)
    assign(:grants, User.grants)

    render
  end
end
