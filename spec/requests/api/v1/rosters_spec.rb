require 'rails_helper'

describe API::V1::RostersController, type: :request do
  let(:api_key) { create(:api_key) }
  let(:roster) { create(:league_roster) }

  describe 'GET #show' do
    let(:route) { '/api/v1/rosters' }

    it 'succeeds for existing roster' do
      get "#{route}/#{roster.id}", headers: { 'X-API-Key' => api_key.key }

      json = JSON.parse(response.body)
      roster_h = json['roster']
      expect(roster_h).to_not be_nil
      expect(roster_h['name']).to eq(roster.name)
      expect(roster_h['division']).to eq(roster.division.name)
      expect(roster_h['players']).to_not be_empty
      expect(roster_h['matches']).to be_empty
      expect(response).to be_success
    end

    it 'succeeds for non-existent roster' do
      get "#{route}/-1", headers: { 'X-API-Key' => api_key.key }

      json = JSON.parse(response.body)
      expect(json['status']).to eq(404)
      expect(json['message']).to eq('Record not found')
      expect(response).to be_not_found
    end
  end
end
