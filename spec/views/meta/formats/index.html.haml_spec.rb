require 'rails_helper'
require 'support/devise'
require 'support/factory_girl'

describe 'meta/formats/index' do
  let!(:formats) { create_list(:format, 5) }

  it 'shows all formats' do
    render

    formats.each do |format|
      expect(rendered).to include(format.name)
    end
  end
end
