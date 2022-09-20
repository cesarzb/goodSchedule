class User < ApplicationRecord
    has_secure_password
    has_many :plans
    validates :username, presence: true, length: { minimum: 3, maximum: 16 }, uniqueness: true
    validates :password, length: { minimum: 8, maximum: 32 }, on: :create

    def token_valid?
        self.token_expiration > Time.now ? true : false
    end
end
