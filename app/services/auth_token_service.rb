class AuthTokenService
    ALGORITHM_TYPE = 'HS256'

    def self.encode#(user_id)
        payload = { user_id: 1 }
        JWT.encode payload, Rails.application.credentials.secret_key_jwt, ALGORITHM_TYPE
    end

    #def decode(token)
    #
    #end
end