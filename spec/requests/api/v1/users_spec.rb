require 'rails_helper'
require 'swagger_helper'

RSpec.describe 'Signup API', type: :request do
  describe '/register' do
    path '/api/v1/register' do
      post 'Returns a token' do
        tags 'Signup'
        consumes 'application/json'
        produces 'application/json'
        parameter name: :signup_data, in: :body, schema: {
          type: :object,
          properties: {
            user: { 
              type: :object, 
              properties: {
                username:              { type: :string, default: 'Student99' },
                password:              { type: :string, default: 'Password1' },
                password_confirmation: { type: :string, default: 'Password1' }
              },
              required: [ 'username', 'password', 'password_confirmation' ]
            }
          }
        }

        response '201', 'signup successful' do
          schema type: :object,
            properties: {
              token: { type: :string, default: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoxfQ.zCGBEiC4n4X5jij4lK4nSEtrbebYxELZ6OfBwdm6CJg' }
            },
            required: [ 'token' ]
          
          let(:signup_data) { { user: FactoryBot.attributes_for(:user) } }

          it 'returns created status for correct username and password' do
            post '/api/v1/register', params: signup_data
            user = User.first

            token = AuthTokenService.encode(user.id)
          
            expect(response).to have_http_status(:created)
            expect(response.body).to eq(
              { token: token }.to_json
            )
          end
        end

        response '422', 'missing or wrong parameter' do
          schema type: :object,
          properties: {
            errors: {
              type: :object,
              properties: {
                password: {
                  type: :array, 
                  properties: [
                    { type: :string, default: "can't be blank" }
                  ]
                },
                username: {
                  type: :array, 
                  properties: [
                    { type: :string, default: "can't be blank" }
                  ]
                },
                password_confirmation: {
                  type: :array, 
                  properties: [
                    { type: :string, default: "can't be blank" }
                  ]
                }
              }
            }
          },
          required: [ 'errors' ],
          example: {
            errors: 
            {
              password:               [ "can't be blank" ],
              password_confirmation:  [ "can't be blank" ],
              username:               [ "can't be blank" ]
            }
          }

          let(:signup_data) { { user: FactoryBot.attributes_for(:user) } }

          it 'returns unprocessable entity status when username is missing' do
            signup_data[:user][:username] = ''
            post '/api/v1/register', params: signup_data
          
            expect(response).to have_http_status(:unprocessable_entity)
            expect(response.body).to eq(
              { errors: { username: [ "can't be blank", "is too short (minimum is 3 characters)"] } }.to_json
            )
          end

          it 'returns unprocessable entity status when password is missing' do
            signup_data[:user][:password] = ''
            post '/api/v1/register', params: signup_data
          
            expect(response).to have_http_status(:unprocessable_entity)
            expect(response.body).to eq(
              { errors: {
                  password: [ "can't be blank", "is too short (minimum is 8 characters)" ],
                  password_confirmation: [ "doesn't match Password"]
                } }.to_json
            )
          end

          it 'returns unprocessable entity status when password confirmation is missing' do
            signup_data[:user][:password_confirmation] = ''
            post '/api/v1/register', params: signup_data
          
            expect(response).to have_http_status(:unprocessable_entity)
            expect(response.body).to eq(
              { errors: { password_confirmation: [ "doesn't match Password", "can't be blank" ] } }.to_json
            )
          end
        end
      end
    end
  end
end
