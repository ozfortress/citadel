require 'rails_helper'

describe 'users/names' do
  let!(:name_changes) { create_list(:user_name_change, 3) }
  let!(:approved_name_changes) { create_list(:user_name_change, 3, approved_by: build(:user)) }
  let!(:denied_name_changes) { create_list(:user_name_change, 3, denied_by: build(:user)) }

  it 'shows all pending name changes' do
    render

    name_changes.each do |name_change|
      expect(rendered).to include(">#{name_change.name}<")
    end

    approved_name_changes.each do |name_change|
      expect(rendered).to_not include(">#{name_change.name}<")
    end

    denied_name_changes.each do |name_change|
      expect(rendered).to_not include(">#{name_change.name}<")
    end
  end
end
