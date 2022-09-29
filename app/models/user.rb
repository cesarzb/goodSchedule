class User < ApplicationRecord
    has_secure_password
    has_many :plans
    validates :username, presence: true, length: { minimum: 3, maximum: 16 }, uniqueness: true
    validates :password, length: { minimum: 8, maximum: 32 }, confirmation: true, on: :create
    validates :password_confirmation, presence: true

    def token_valid?
        self.token_expiration > Time.now ? true : false
    end
end
