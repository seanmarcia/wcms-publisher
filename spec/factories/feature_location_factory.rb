FactoryGirl.define do
  factory :feature_location do
    sequence(:title) { |n| "Title ##{n}" }
    url Faker::Internet.url
    site
  end
end
