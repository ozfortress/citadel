require 'rails_helper'

describe API::V1::UsersController, type: :request do
  let(:api_key) { create(:api_key) }
  let(:user) { create(:user) }

  describe 'GET #show' do
    let(:route) { '/api/v1/users' }

    it 'succeeds for existing user' do
      teams = create_list(:team, 3)
      teams.each { |team| team.add_player!(user) }
      rosters = create_list(:league_roster, 2)
      rosters.each { |roster| roster.add_player!(user) }

      get "#{route}/#{user.id}", headers: { 'X-API-Key' => api_key.key }

      json = response.parsed_body
      user_h = json['user']
      expect(user_h).to_not be_nil
      expect(user_h['name']).to eq(user.name)

      expect(user_h['rosters'].length).to eq(rosters.length)
      user_h['rosters'].each do |roster|
        expect(rosters.map(&:id)).to include(roster['id'])
      end

      expect(user_h['teams'].length).to eq(teams.length)
      user_h['teams'].each do |team|
        expect(teams.map(&:id)).to include(team['id'])
      end

      expect(response).to be_success
    end

    it 'succeeds for non-existent user' do
      get "#{route}/-1", headers: { 'X-API-Key' => api_key.key }

      json = response.parsed_body
      expect(json['status']).to eq(404)
      expect(json['message']).to eq('Record not found')
      expect(response).to be_not_found
    end

    it 'fails without authorization' do
      get "#{route}/#{user.id}"

      json = response.parsed_body
      expect(json['status']).to eq(401)
      expect(json['message']).to eq('Unauthorized API key')
    end
  end

  describe 'GET #steam_id' do
    let(:route) { '/api/v1/users/steam_id' }

    it 'succeeds for existing user' do
      get "#{route}/#{user.steam_id}", headers: { 'X-API-Key' => api_key.key }

      json = response.parsed_body
      user_h = json['user']
      expect(user_h).to_not be_nil
      expect(user_h['name']).to eq(user.name)
      expect(user_h['teams']).to be_empty
      expect(user_h['rosters']).to be_empty
      expect(response).to be_success
    end

    it 'succeeds for non-existent user' do
      get "#{route}/0", headers: { 'X-API-Key' => api_key.key }

      json = response.parsed_body
      expect(json['status']).to eq(404)
      expect(json['message']).to eq('Record not found')
      expect(response).to be_not_found
    end
  end
end
