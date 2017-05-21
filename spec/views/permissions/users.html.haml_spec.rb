require 'rails_helper'

describe 'permissions/users' do
  let(:users_with_permission) { build_stubbed_list(:user, 2) }
  let(:users_without_permission) { build_stubbed_list(:user, 5) }
  let(:team) { build_stubbed(:team) }

  it 'shows for team permissions' do
    assign(:users_with_permission, users_with_permission)
    assign(:users_without_permission, users_without_permission.paginate(page: 1))
    assign(:action, :edit)
    assign(:subject, :team)
    assign(:target, team)

    render
  end

  it 'shows for other permissions' do
    assign(:users_with_permission, users_with_permission)
    assign(:users_without_permission, users_without_permission.paginate(page: 1))
    assign(:action, :edit)
    assign(:subject, :teams)
    assign(:target, :teams)

    render
  end
end
