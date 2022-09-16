require 'rails_helper'
require 'swagger_helper'

RSpec.describe 'Authentication API', type: :request do
  describe '/authenticate' do    
    
  path '/api/v1/authenticate' do
    post 'Returns a token' do
      tags 'Authentication'
      consumes 'application/json'
      parameter name: :login_data, in: :body, schema: {
        type: :object,
        properties: {
          username: { type: :string, default: 'Student99' },
          password: { type: :string, default: 'Password1' }
        }, 
        required: [ 'username', 'password' ]
      }
  
      response '200', 'authentication successful' do
        let(:user) { FactoryBot.create(:user) }
        
        it 'returns success status for username and password' do
          post '/api/v1/authenticate', params: { username: user.username, password: user.password }
        
          token = AuthTokenService.encode(user.id)
        
          expect(response).to have_http_status(:ok)
          expect(response.body).to eq(
            { token: token }.to_json
          )
        end

        schema type: :object,
          properties: {
            token: { type: :string, default: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoxfQ.zCGBEiC4n4X5jij4lK4nSEtrbebYxELZ6OfBwdm6CJg' }
          }
      end
  
      response '401', "missing parameter (password or username) or they're wrong" do
        let(:user) { FactoryBot.create(:user) }

        it 'returns unauthorized when username is missing' do
          post '/api/v1/authenticate', params: { password: user.password }
        
          expect(response).to have_http_status(:unauthorized)
          expect(response.body).to eq(
            { error: 'param is missing or the value is empty: username' }.to_json
          )
        end

        it 'returns unauthorized when password is missing' do
          post '/api/v1/authenticate', params: { username: user.username }
        
          expect(response).to have_http_status(:unauthorized)
          expect(response.body).to eq(
            { error: 'param is missing or the value is empty: password' }.to_json
          )
        end

        it 'returns unauthorized when password is incorrect' do
          post '/api/v1/authenticate', params: { username: user.username, password: 'incorrect' }
        
          expect(response).to have_http_status(:unauthorized)
          expect(response.body).to eq(
            { error: 'Username or password is incorrect' }.to_json
          )
        end

        schema type: :object,
          properties: {
              error: { type: :string, default: 'param is missing or the value is empty: username' }
          }
        end
      end
    end
  end
end
