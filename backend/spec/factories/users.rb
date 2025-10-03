FactoryBot.define do
  factory :user do
    name { Faker::Name.name }
    email { Faker::Internet.unique.email }
    password { "password123" }
    password_confirmation { "password123" }

    trait :with_trips do
      after(:create) do |user|
        create_list(:trip, 3, user: user)
      end
    end
  end
end
