FactoryBot.define do
  factory :template do
    name { Faker::Lorem.words(number: 2).join(' ') }
    description { Faker::Lorem.paragraph }
    category { Template.categories.keys.sample }
    active { true }
    
    trait :with_images do
      after(:build) do |template|
        template.preview_image.attach(
          io: File.open(Rails.root.join('spec', 'fixtures', 'files', 'preview.jpg')),
          filename: 'preview.jpg',
          content_type: 'image/jpeg'
        )
        
        template.background_image.attach(
          io: File.open(Rails.root.join('spec', 'fixtures', 'files', 'background.jpg')),
          filename: 'background.jpg',
          content_type: 'image/jpeg'
        )
      end
    end
  end
end
