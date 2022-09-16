require 'rails_helper'

RSpec.describe ApplicationController, type: :controller do
    let!(:user) { FactoryBot.create(:user) }

    controller do
        def index
            authenticate_user
        end
    end

    it 'returns unauthorized for invalid token' do
        get :index, params: { token: AuthTokenService.encode(user.id + 1) }

        expect(response).to have_http_status(:unauthorized)
    end

    it 'returns unauthorized when the token is missing' do
        get :index, params: {}

        expect(response).to have_http_status(:unauthorized)
    end
end