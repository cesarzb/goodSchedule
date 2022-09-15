require 'rails_helper'
require 'swagger_helper'

RSpec.describe 'Authentication API', type: :request do
  describe '/authenticate' do
    it 'returns success status for username and password' do
      post '/api/v1/authenticate', params: { username: 'Student99', password: 'Password1' }
    
      token = AuthTokenService.encode
    
      expect(response).to have_http_status(:ok)
      expect(response.body).to eq(
        { token: token }.to_json
      )
    end   
    
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
  #path '/api/v1/authenticate' do
  #  post 'Returns a token' do
  #    tags 'Authentication'
  #    consumes 'application/json'
  #    parameter name: :login_data, in: :body, schema: {
  #      type: :object,
  #      properties: {
  #        username: { type: :string },
  #        password: { type: :string }
  #      }, 
  #      required: [ 'username', 'password' ]
  #    }
  #
  #    response '200', 'authentication successful' do
  #      let(:login_data) { { username: 'Student99', password: 'Password1' } }
  #      run_test!
  #    end
  #
  #    response '401', 'missing password' do
  #      let(:login_data) { { username: 'Student99' } }
  #      run_test!
  #    end
  #    
  #    response '401', 'missing username' do
  #      let(:login_data) { { password: 'Password1' } }
  #      run_test!
  #    end
  #  end
  #end
  end
end
