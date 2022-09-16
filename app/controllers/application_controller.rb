class ApplicationController < ActionController::API
    include ActionController::HttpAuthentication::Token
    
    def authenticate_user
        token, _options = token_and_options(request)
        user_id = AuthTokenService.decode(token)
        User.find(user_id)
    rescue ActiveRecord::RecordNotFound, JWT::DecodeError
        render status: :unauthorized
    end
end
