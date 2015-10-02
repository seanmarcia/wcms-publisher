FactoryGirl.define do
  factory :service_link do
    sequence(:title) {|n| Faker::Company.catch_phrase + "#{n}"}
    sequence(:slug) {|n| Faker::Internet.slug(nil, '-') + "#{n}"}

    trait :with_logo do
      logo { File.open('spec/fixtures/upload.png') }
    end
  end
end
