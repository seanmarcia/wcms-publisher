FactoryGirl.define do
  factory :user do
    first_name { Faker::Name.first_name }
    last_name  { Faker::Name.last_name }
    username   { Faker::Internet.user_name }
    biola_id   { Faker::Number.number(9) }
    title      { Faker::Name.title }
    email      { Faker::Internet.email }
    photo_url  { Faker::Internet.url('example.com', '/#{username}.jpg') }
    department { Faker::Commerce.department }

    affiliations { [] }
    entitlements { [] }
  end
end
