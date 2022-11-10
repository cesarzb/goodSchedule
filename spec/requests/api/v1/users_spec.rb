require 'rails_helper'
require 'swagger_helper'

RSpec.describe 'Users API', type: :request do
  path '/api/v1/register' do
    post 'Returns a token' do
      tags 'User'
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

  path '/api/v1/change-password' do
    post 'Returns OK' do
      tags 'User'
      security [ bearer_auth: [] ]
      consumes 'application/json'
      produces 'application/json'
      parameter name: :password_data, in: :body, schema: {
        type: :object,
        properties: {
          password:              { type: :string, default: 'new_password' },
          password_confirmation: { type: :string, default: 'new_password' }
        },
        required: [ 'password', 'password_confirmation' ]
      }

      let!(:user)           { FactoryBot.create(:user) }
      let!(:Authorization)  { "Bearer #{AuthTokenService.encode(user.id)}" }
      let!(:valid_header)   { { "Authorization": "Bearer #{AuthTokenService.encode(user.id)}" } }
      
      response '200', 'password change successful' do
        let(:password_data)   { { password: 'new_password', password_confirmation: 'new_password' } }
        it 'changes users password for valid data' do
          post '/api/v1/change-password', params: password_data, headers: valid_header
          user.reload

          expect(response).to have_http_status(:ok)
          expect(user.authenticate('new_password')).to eq(user)
        end

        run_test!
      end

      response '422', 'password change unsuccessful' do
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
        errors: 
        {
          "Username or password": [ 'is incorrect' ]
        }
      }

        let(:password_data)   { { password: 'new_password', password_confirmation: '' } }
        it 'changes users password for valid data' do
          post '/api/v1/change-password', params: password_data, headers: valid_header
          user.reload

          expect(response).to have_http_status(:unprocessable_entity)
          expect(user.authenticate('new_password')).to eq(false)
        end

        run_test!
      end
    end
  end

  path "/api/v1/users/{id}" do 
    get 'Returns specified user' do
      tags 'User'
      security [ bearer_auth: [] ]
      produces 'application/json'
      parameter name: :id, in: :path, type: :integer

      let!(:user)           { FactoryBot.create(:user) }
      let!(:other_user)           { FactoryBot.create(:user) }
      let!(:Authorization)  { "Bearer #{AuthTokenService.encode(user.id)}" }
      let!(:valid_header)   { { "Authorization": "Bearer #{AuthTokenService.encode(user.id)}" } }

      response '200', 'when user exists' do
        schema type: :object,
        properties: {
          id:              { type: :integer, default: 1 },
          username:        { type: :string, default: 'Student99' },
          created_at:      { type: :date, default: '2022-09-20T10:45:38.966Z' },
          number_of_plans: { type: :integer, default: 1 }
        },
        required: [ 'id', 'username', 'created_at', 'number_of_plans' ],
        example: {
            id: 1,
            username: 'Student99',
            created_at: '2022-09-20T10:45:38.966Z',
            number_of_plans: 1
        }
        
        let(:id) { user.id }
        run_test!
      end

      response '401', 'user is unauthorized' do
        let!(:Authorization)  { nil }
        
        it "returns unauthorized when normal user tries to access other user's data" do
          get "/api/v1/users/#{other_user.id}", headers: valid_header

          expect(response).to have_http_status(:unauthorized)
        end

        let(:id) { user.id }
        run_test!
      end

      # test for admin role
      # response '404', "user with specified id doesn't exist" do        
      #   let(:id) { plan.id + 1}
      #   run_test!
      # end
    end
  end

  path "/api/v1/remote-storage" do 
    get 'Returns settings JSON' do
      tags 'User'
      security [ bearer_auth: [] ]
      produces 'application/json'
      parameter name: :id, in: :path, type: :integer

      let!(:user)           { FactoryBot.create(:user) }
      let!(:other_user)           { FactoryBot.create(:user) }
      let!(:Authorization)  { "Bearer #{AuthTokenService.encode(user.id)}" }
      let!(:valid_header)   { { "Authorization": "Bearer #{AuthTokenService.encode(user.id)}" } }

      response '200', 'when user exists' do
        schema type: :object,
        properties: {
          id:              { type: :integer, default: 1 },
          username:        { type: :string, default: 'Student99' },
          created_at:      { type: :date, default: '2022-09-20T10:45:38.966Z' },
          number_of_plans: { type: :integer, default: 1 }
        },
        required: [ 'id', 'username', 'created_at', 'number_of_plans' ],
        example: {
            id: 1,
            username: 'Student99',
            created_at: '2022-09-20T10:45:38.966Z',
            number_of_plans: 1
        }
        
        let(:id) { user.id }
        run_test!
      end
    end

    post 'Edits settings JSON' do
      tags 'User'
      security [ bearer_auth: [] ]
      produces 'application/json'
      parameter name: :id, in: :path, type: :integer

      let!(:user)           { FactoryBot.create(:user) }
      let!(:other_user)           { FactoryBot.create(:user) }
      let!(:Authorization)  { "Bearer #{AuthTokenService.encode(user.id)}" }
      let!(:valid_header)   { { "Authorization": "Bearer #{AuthTokenService.encode(user.id)}" } }

      response '200', 'when user exists' do
        schema type: :object,
        properties: {
          id:              { type: :integer, default: 1 },
          username:        { type: :string, default: 'Student99' },
          created_at:      { type: :date, default: '2022-09-20T10:45:38.966Z' },
          number_of_plans: { type: :integer, default: 1 }
        },
        required: [ 'id', 'username', 'created_at', 'number_of_plans' ],
        example: {
            id: 1,
            username: 'Student99',
            created_at: '2022-09-20T10:45:38.966Z',
            number_of_plans: 1
        }
        
        let(:id) { user.id }
        run_test!
      end
    end
  end
end
