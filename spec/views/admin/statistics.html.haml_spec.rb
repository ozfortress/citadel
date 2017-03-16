require 'rails_helper'

describe 'admin/statistics' do
  it 'displays' do
    assign(:timeframe, 30.minutes)
    assign(:events_per_second, 1)
    assign(:users_count, 2)
    assign(:api_keys_count, 3)
    assign(:teams_count, 4)
    assign(:matches_count, 5)
    assign(:match_comms_count, 6)
    assign(:match_comm_edits_count, 7)

    render
  end
end
