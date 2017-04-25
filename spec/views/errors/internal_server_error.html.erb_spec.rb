require 'rails_helper'

describe 'errors/internal_server_error.html.haml' do
  it 'renders' do
    render

    expect(rendered).to include('500')
  end
end
