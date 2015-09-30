FactoryGirl.define do
  factory :site do
    sequence(:title) { |n| "Title ##{n}" }
    url Faker::Internet.url
  end
end
