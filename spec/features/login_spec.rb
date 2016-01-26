require 'support/omniauth'
require 'support/capybara'

feature 'User tries to login with steam' do
  scenario 'for the first time' do
    visit teams_path

    mock_auth_hash(name: 'Kenneth')
    find('#login').click

    expect(current_url).to eq(new_user_url(name: 'Kenneth'))
  end

  scenario 'when already registered' do
    user = create(:user)
    visit teams_path

    mock_auth_hash(name: user.name, steam_id: user.steam_id)
    find('#login').click

    expect(current_path).to eq('/')
  end
end
