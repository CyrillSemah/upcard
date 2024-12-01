FactoryBot.define do
  factory :invitation do
    card
    guest_email { Faker::Internet.email }
    guest_name { Faker::Name.name }
    status { :pending }
    token { SecureRandom.urlsafe_base64(32) }
    
    trait :accepted do
      status { :accepted }
    end
    
    trait :declined do
      status { :declined }
    end
    
    trait :responded do
      status { [:accepted, :declined].sample }
    end
  end
end
