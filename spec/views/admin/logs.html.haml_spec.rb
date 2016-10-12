require 'rails_helper'

describe 'admin/logs' do
  before do
    user = create(:user)
    create_list(:ahoy_event, 5, user: user)
    create_list(:ahoy_event, 5, user: nil)
  end

  it 'displays' do
    assign(:events_per_second, 1)
    assign(:users_count, 2)
    assign(:teams_count, 3)
    assign(:matches_count, 4)
    assign(:match_comms_count, 5)
    assign(:events, Ahoy::Event.all.paginate(page: 1))

    render
  end
end
