require 'rails_helper'

describe 'permissions/users' do
  let(:users) { build_stubbed_list(:user, 5) }
  let(:team) { build_stubbed(:team) }
  let(:admin) { users.sample }

  before do
    allow(admin).to receive(:can?).and_return(true)
  end

  it 'shows all teams' do
    assign(:users, users.paginate(page: 1))
    assign(:action, :edit)
    assign(:subject, :team)
    assign(:target, team)

    render
  end
end
