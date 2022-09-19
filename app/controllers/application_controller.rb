class ApplicationController < ActionController::API
    include ActionController::HttpAuthentication::Token
        class TokenExpired < StandardError; end

    def authenticate_user
        token, _options = token_and_options(request)
        user_id = AuthTokenService.decode(token)
        raise TokenExpired unless User.find(user_id).token_valid?
    rescue ActiveRecord::RecordNotFound, JWT::DecodeError, TokenExpired
        render status: :unauthorized
    end
end
