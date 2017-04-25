require 'rails_helper'

feature 'User accesses invalid page' do
  # Make it like we're accessing in production
  around :each do |example|
    Rails.application.config.consider_all_requests_local = false
    Rails.application.config.action_dispatch.show_exceptions = true
    example.run
    Rails.application.config.consider_all_requests_local = true
    Rails.application.config.action_dispatch.show_exceptions = false
  end

  scenario 'authenticated user' do
    visit team_path(-1)

    expect(page).to have_content '404'
  end

  scenario 'unauthenticated user' do
    visit team_path(-1)

    expect(page).to have_content '404'
  end
end
