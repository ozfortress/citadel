require 'rails_helper'
require 'support/devise'
require 'support/factory_girl'

describe 'admin/logs' do
  it 'displays' do
    view.lookup_context.prefixes = %w(application)
    assign(:events_per_second, 1)
    assign(:users_count, 2)
    assign(:teams_count, 3)
    assign(:matches_count, 4)
    assign(:match_comms_count, 5)
    assign(:events, Ahoy::Event.all.paginate(page: 1))

    render
  end
end
