FactoryBot.define do
  factory :user do
    username              { Faker::Name.name[3..16] }
    password              { "Password1" }
    password_confirmation { "Password1" }
    token_expiration      { 14.days.from_now }
  end
end
