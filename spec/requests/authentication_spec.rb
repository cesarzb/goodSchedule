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
        let(:login_data) { { username: 'Student99', password: 'Password1' } }
        it 'returns success status for username and password' do
          post '/api/v1/authenticate', params: { username: 'Student99', password: 'Password1' }
        
          token = AuthTokenService.encode
        
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

          it 'returns unauthorized when username is missing' do
            post '/api/v1/authenticate', params: { password: 'Password1' }
          
            expect(response).to have_http_status(:unauthorized)
            expect(response.body).to eq(
              { error: 'param is missing or the value is empty: username' }.to_json
            )
          end

          it 'returns unauthorized when password is missing' do
            post '/api/v1/authenticate', params: { username: 'Student99' }
          
            expect(response).to have_http_status(:unauthorized)
            expect(response.body).to eq(
              { error: 'param is missing or the value is empty: password' }.to_json
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
