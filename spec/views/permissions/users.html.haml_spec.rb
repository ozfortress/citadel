require 'rails_helper'

describe 'permissions/users' do
  let(:users) { create_list(:user, 4) }
  let(:team) { create(:team) }
  let(:user) { create(:user) }

  before do
    user.grant(:edit, :teams)
  end

  it 'shows all teams' do
    sign_in user
    assign(:users, User.paginate(page: 1))
    assign(:action, :edit)
    assign(:subject, :team)
    assign(:target, team.id)

    render
  end
end
