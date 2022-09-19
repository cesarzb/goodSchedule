class User < ApplicationRecord
    has_secure_password
    validates :username, presence: true, length: { minimum: 3, maximum: 16 }
    validates :password, length: { minimum: 8, maximum: 32 }

    def token_valid?
        self.token_expiration > Time.now ? true : false
    end
end
