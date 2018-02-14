require 'rails_helper'

describe API::V1::TeamsController, type: :request do
  let(:api_key) { create(:api_key) }
  let(:team) { create(:team) }

  describe 'GET #show' do
    let(:route) { '/api/v1/teams' }

    it 'succeeds for existing team' do
      players = create_list(:team_player, 3, team: team)
      rosters = create_list(:league_roster, 2, team: team)

      get "#{route}/#{team.id}", headers: { 'X-API-Key' => api_key.key }

      json = response.parsed_body
      team_h = json['team']
      expect(team_h).to_not be_nil
      expect(team_h['name']).to eq(team.name)

      expect(team_h['players'].length).to eq(players.length)
      team_h['players'].each do |user|
        expect(players.map(&:user_id)).to include(user['id'])
      end

      expect(team_h['rosters'].length).to eq(rosters.length)
      team_h['rosters'].each do |roster|
        expect(rosters.map(&:id)).to include(roster['id'])
      end

      expect(response).to be_success
    end

    it 'succeeds for non-existent team' do
      get "#{route}/-1", headers: { 'X-API-Key' => api_key.key }

      json = response.parsed_body
      expect(json['status']).to eq(404)
      expect(json['message']).to eq('Record not found')
      expect(response).to be_not_found
    end

    it 'fails without authorization' do
      get "#{route}/#{team.id}"

      json = response.parsed_body
      expect(json['status']).to eq(401)
      expect(json['message']).to eq('Unauthorized API key')
    end
  end
end
