FactoryGirl.define do
  factory :important_date do
    title { Faker::Lorem.sentence }
    start_date { Faker::Date.between(1.day.from_now, 3.months.from_now) }
  end
end
