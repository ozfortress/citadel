require 'rails_helper'

describe 'admin/logs' do
  before do
    @visits = []

    user = create(:user)
    @visits << create(:visit, user: user)

    api_key = create(:api_key)
    @visits << create(:visit, api_key: api_key)

    @visits.each do |visit|
      create_list(:ahoy_event, 2, visit: visit)
    end
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
