FactoryGirl.define do
  factory :calendar do
    sequence(:title) {|n| "calendar#{n}" }
    sequence(:start_date) {|n| Date.parse('2013-06-01') + n.year }
    sequence(:end_date) {|n| Date.parse('2014-06-01') + n.year - 1.day }
  end
end
