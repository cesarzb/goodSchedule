require 'rails_helper'
require 'swagger_helper'

RSpec.describe 'Authentication API', type: :request do
  path '/api/v1/login' do
    post 'Returns a token' do
      tags 'Authentication'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :login_data, in: :body, schema: {
        type: :object,
        properties: {
          user: { 
            type: :object, 
            properties: {
              username: { type: :string, default: 'Student99' },
              password: { type: :string, default: 'Password1' }
            },
            required: [ 'username', 'password' ]
          }
        }
      }
  
      response '200', 'authentication successful' do
        let(:user) { FactoryBot.create(:user) }
        
        it 'returns success status for username and password' do
          post '/api/v1/login', params: { user: { username: user.username, password: user.password } }
        
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
  
      response '401', "missing or incorrect parameter (password or username)" do
        let(:user) { FactoryBot.create(:user) }

        it 'returns unauthorized when username is missing' do
          post '/api/v1/login', params: { user: { password: user.password } }
        
          expect(response).to have_http_status(:unauthorized)
          expect(response.body).to eq(
            { errors: { 'Username': [ 'param is missing or the value is empty' ] } }.to_json
          )
        end

        it 'returns unauthorized when password is missing' do
          post '/api/v1/login', params: { user: { username: user.username } }
        
          expect(response).to have_http_status(:unauthorized)
          expect(response.body).to eq(
            { errors: { 'Password': [ 'param is missing or the value is empty' ] } }.to_json
          )
        end

        it 'returns unauthorized when password is incorrect' do
          post '/api/v1/login', params: { user: { username: user.username, password: 'incorrect' } }
        
          expect(response).to have_http_status(:unauthorized)
          expect(response.body).to eq(
            { errors: { 'Username or password': ['is incorrect' ] } }.to_json
          )
        end

        schema type: :object,
          properties: {
            errors: {
            type: :object,
            properties: {
              "Username or password": {
                type: :array, 
                properties: [
                  { type: :string, default: 'is incorrect' }
                ]
              }
            }
          }
        },
        required: [ 'errors' ],
        example: {
          errors: {
            "Username or password": [ 'is incorrect' ]
          }
        }
      end
    end
  end
end

describe 'deauthenticate' do

  #let(:authorization) { "Bearer #{AuthTokenService.encode(user.id)}" }

  path '/api/v1/logout' do
    delete 'Returns no content' do
      tags 'Authentication'
      security [ bearer_auth: [] ]

      response '204', 'user deauthenticated successfully' do
        let!(:user) { FactoryBot.create(:user) }
        let!(:Authorization) { "Bearer #{AuthTokenService.encode(user.id)}" }
        run_test!
      end
    end
  end
end
