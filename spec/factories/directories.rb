FactoryBot.define do
  factory :directory do
    sequence(:name) { |n| "Directory#{n}" }
    
    trait :with_parent do
      association :parent, factory: :directory
    end

    trait :with_files do
      after(:create) do |directory|
        directory.files.attach(
          io: StringIO.new('test content'),
          filename: 'test.txt',
          content_type: 'text/plain'
        )
      end
    end
  end
end 
