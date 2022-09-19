class User < ApplicationRecord
    has_secure_password
    validates :username, presence: true

    def token_valid?
        self.token_expiration > Time.now ? true : false
    end
end
