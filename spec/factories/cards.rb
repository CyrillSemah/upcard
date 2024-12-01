FactoryBot.define do
  factory :card do
    title { Faker::Lorem.sentence }
    description { Faker::Lorem.paragraph }
    event_date { Faker::Date.forward(days: 30) }
    event_type { Card.event_types.keys.sample }
    status { :draft }
    user
    template
    
    trait :published do
      status { :published }
    end
    
    trait :archived do
      status { :archived }
    end
    
    trait :with_cover_image do
      after(:build) do |card|
        card.cover_image.attach(
          io: File.open(Rails.root.join('spec', 'fixtures', 'files', 'cover.jpg')),
          filename: 'cover.jpg',
          content_type: 'image/jpeg'
        )
      end
    end
    
    trait :with_invitations do
      after(:create) do |card|
        create_list(:invitation, 3, card: card)
      end
    end
  end
end
