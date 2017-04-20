require 'rails_helper'

describe 'users/names' do
  let(:name_changes) { build_stubbed_list(:user_name_change, 5) }

  it 'shows all pending name changes' do
    assign(:name_changes, name_changes)

    render

    name_changes.each do |name_change|
      expect(rendered).to include(">#{name_change.name}<")
    end
  end
end
