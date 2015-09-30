FactoryGirl.define do
  factory :page_edition do
    site
    sequence(:title) {|n| Faker::Company.catch_phrase + "#{n}"}
    sequence(:slug) {|n| Faker::Internet.slug(nil, '-') + "#{n}"}
  end
end
