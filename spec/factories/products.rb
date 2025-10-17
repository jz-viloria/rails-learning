FactoryBot.define do
  factory :product do
    name { Faker::Commerce.product_name }
    description { Faker::Lorem.paragraph(sentence_count: 3) }
    price { Faker::Commerce.price(range: 10.0..500.0) }
    image_url { Faker::LoremFlickr.image(size: "500x500", search_terms: ['product']) }
    stock_quantity { Faker::Number.between(from: 0, to: 100) }
    featured { Faker::Boolean.boolean }
    category { Faker::Commerce.department }
    brand { Faker::Company.name }
    sku { "SKU-#{Faker::Alphanumeric.alphanumeric(number: 6).upcase}" }

    trait :featured do
      featured { true }
    end

    trait :out_of_stock do
      stock_quantity { 0 }
    end

    trait :low_stock do
      stock_quantity { Faker::Number.between(from: 1, to: 9) }
    end

    trait :electronics do
      category { 'Electronics' }
      brand { 'TechCorp' }
    end

    trait :clothing do
      category { 'Clothing' }
      brand { 'FashionBrand' }
    end
  end
end
