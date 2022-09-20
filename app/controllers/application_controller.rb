class ApplicationController < ActionController::API
    include ActionController::HttpAuthentication::Token
        class TokenExpired < StandardError; end

    def authenticate_user
        token, _options = token_and_options(request)
        user_id = AuthTokenService.decode(token)
        #@current_user = User.find(user_id)
        raise TokenExpired unless User.find(user_id).token_valid?
    rescue ActiveRecord::RecordNotFound, JWT::DecodeError, TokenExpired
        render status: :unauthorized
    end

    def not_found
        render status: :not_found
    end
end
