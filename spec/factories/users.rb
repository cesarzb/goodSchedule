FactoryBot.define do
  factory :user do
    username { Faker::Name.name }
    password { "Password1" }
  end
end
