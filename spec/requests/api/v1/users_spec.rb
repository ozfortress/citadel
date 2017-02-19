require 'rails_helper'

describe API::V1::UsersController, type: :request do
  let(:user) { create(:user) }

  describe 'GET #show' do
    let(:route) { '/api/v1/users' }

    it 'succeeds for existing user' do
      get "#{route}/#{user.id}"

      json = JSON.parse(response.body)
      user_h = json['user']
      expect(user_h).to_not be_nil
      expect(user_h['name']).to eq(user.name)
      expect(user_h['rosters']).to be_empty
      expect(response).to be_success
    end

    it 'succeeds for non-existent user' do
      get "#{route}/-1"

      json = JSON.parse(response.body)
      expect(json['status']).to eq(404)
      expect(json['message']).to eq('Record not found')
      expect(response).to be_not_found
    end
  end
end
