require 'rails_helper'

describe 'admin/logs' do
  before do
    view.lookup_context.prefixes = %w(application)

    create_list(:ahoy_event, 20)
    create_list(:ahoy_event, 10, user: nil)
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
