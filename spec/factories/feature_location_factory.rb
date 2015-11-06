FactoryGirl.define do
  factory :feature_location do
    sequence(:title) { |n| "Title ##{n}" }
    sequence(:path) { |n| "/path/to/#{n}"}
    sequence(:slug) { |n| "slug-#{n}"}

    site
  end
end
