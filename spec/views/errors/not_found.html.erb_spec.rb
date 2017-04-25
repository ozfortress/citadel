require 'rails_helper'

describe 'errors/not_found.html.haml' do
  it 'renders' do
    render

    expect(rendered).to include('404')
  end
end
