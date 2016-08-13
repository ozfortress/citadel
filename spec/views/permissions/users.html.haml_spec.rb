require 'rails_helper'
require 'support/devise'
require 'support/factory_girl'

describe 'permissions/users' do
  let(:users) { create_list(:user, 4) }
  let(:team) { create(:team) }
  let(:user) { create(:user) }

  before do
    user.grant(:edit, :teams)
  end

  it 'shows all teams' do
    view.lookup_context.prefixes = %w(application)
    sign_in user
    assign(:users, User.paginate(page: 1))
    assign(:action, :edit)
    assign(:subject, :team)
    assign(:target, team.id)

    render
  end
end
