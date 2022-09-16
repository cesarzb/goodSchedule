FactoryBot.define do
  factory :user do
    username         { Faker::Name.name }
    password         { "Password1" }
    token_expiration { 14.days.from_now }
  end
end
