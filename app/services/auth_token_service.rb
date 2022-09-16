class AuthTokenService
    ALGORITHM_TYPE = 'HS256'

    def self.encode(user_id)
        payload = { user_id: user_id }
        JWT.encode payload, Rails.application.credentials.secret_key_jwt, ALGORITHM_TYPE
    end

    def self.decode(token)
        decoded_token = JWT.decode token, Rails.application.credentials.secret_key_jwt, true, { algorithm: ALGORITHM_TYPE }
        return decoded_token[0]['user_id']
    end
end