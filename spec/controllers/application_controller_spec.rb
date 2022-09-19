require 'rails_helper'

RSpec.describe ApplicationController, type: :controller do
    let!(:user) { FactoryBot.create(:user) }

    controller do
        def index
            authenticate_user
        end
    end

    context 'with token' do        
        it "returns unauthorized when user doesn't exist" do
            headers = { 'Authorization': "Bearer #{AuthTokenService.encode(user.id + 1)}" }
            request.headers.merge! headers
            get :index, params: {}

            expect(response).to have_http_status(:unauthorized)
        end

        it "returns unauthorized when token is expired" do
            headers = { 'Authorization': "Bearer #{AuthTokenService.encode(user.id)}" }
            request.headers.merge! headers
            user.update(token_expiration: Time.now)
            get :index, params: {}
        
            expect(response).to have_http_status(:unauthorized)
        end

        it "returns unauthorized when token is not JWT" do
            headers = { 'Authorization': "Bearer 123" }
            request.headers.merge! headers
            get :index, params: {}
        
            expect(response).to have_http_status(:unauthorized)
        end

        it "returns no content when token is valid" do
            headers = { 'Authorization': "Bearer #{AuthTokenService.encode(user.id)}" }
            request.headers.merge! headers
            get :index, params: {}

            expect(response).to have_http_status(:no_content)
        end
    end

    context 'with missing token' do
        it 'returns unauthorized' do
            get :index, params: {}
        
            expect(response).to have_http_status(:unauthorized)
        end
    end
end