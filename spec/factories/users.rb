FactoryBot.define do
  factory :user do
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    email { Faker::Internet.unique.email }
    phone { Faker::PhoneNumber.phone_number }
    password { 'password123' }
    password_confirmation { 'password123' }
    
    # Address information
    address_line1 { Faker::Address.street_address }
    address_line2 { Faker::Address.secondary_address }
    city { Faker::Address.city }
    state { Faker::Address.state_abbr }
    zip_code { Faker::Address.zip_code }
    country { 'US' }
    
    # Preferences
    email_notifications { true }
    sms_notifications { false }
    
    # Account status
    active { true }
    last_login_at { Faker::Time.between(from: 1.month.ago, to: Time.current) }

    trait :inactive do
      active { false }
    end

    trait :without_address do
      address_line1 { nil }
      address_line2 { nil }
      city { nil }
      state { nil }
      zip_code { nil }
    end

    trait :with_orders do
      after(:create) do |user|
        create_list(:order, 3, user: user)
      end
    end

    trait :admin do
      first_name { 'Admin' }
      last_name { 'User' }
      email { 'admin@example.com' }
    end
  end
end
