require 'rails_helper'

RSpec.describe 'POST /signup', type: :request do
  let(:url) { '/signup' }


  context 'when user is unauthenticated' do
    let(:params) do
      {
        user: {
          email: 'new_user@email.com',
          password: 'password'
        }
      }
    end
    before { post url, params: params }

    it 'returns 200' do
      expect(response.status).to eq 200
    end

    it 'returns a new user' do
      expect(json['email']).to eq'new_user@email.com'
    end
  end

  context 'when user already exists' do
    let!(:user) { create(:user)}
    let(:params) do
      {
        user: {
          email: user.email,
          password: user.password
        }
      }
    end
    before do
      post url, params: params
    end

    it 'returns bad request status' do
      expect(response.status).to eq 400
    end

    it 'returns validation errors' do
      expect(json['errors'].first['title']).to eq('Bad Request')
    end
  end
end