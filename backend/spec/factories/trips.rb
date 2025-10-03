FactoryBot.define do
  factory :trip do
    association :user
    title { Faker::Lorem.sentence(word_count: 3) }
    description { Faker::Lorem.paragraph }
    start_date { Faker::Date.forward(days: 30) }
    end_date { start_date + rand(1..14).days }

    trait :without_dates do
      start_date { nil }
      end_date { nil }
    end

    trait :with_invalid_dates do
      start_date { Time.zone.today }
      end_date { Time.zone.today - 1.day }
    end

    trait :past_trip do
      start_date { Faker::Date.backward(days: 30) }
      end_date { start_date + rand(1..7).days }
    end

    trait :ongoing_trip do
      start_date { Time.zone.today - 5.days }
      end_date { Time.zone.today + 5.days }
    end
  end
end
