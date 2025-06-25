FactoryBot.define do
  factory :directory do
    sequence(:name) { |n| "Directory#{n}" }
  end
end
