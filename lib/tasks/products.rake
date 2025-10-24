namespace :products do
  desc "Add sample products to the database"
  task add_samples: :environment do
    puts "Adding sample products..."
    
    products = [
      {
        name: "Wireless Headphones",
        description: "High-quality wireless headphones with noise cancellation and 30-hour battery life",
        price: 99.99,
        image_url: "https://example.com/headphones.jpg"
      },
      {
        name: "Smart Watch",
        description: "Fitness tracking smart watch with heart rate monitor and GPS",
        price: 199.99,
        image_url: "https://example.com/smartwatch.jpg"
      },
      {
        name: "Bluetooth Speaker",
        description: "Portable Bluetooth speaker with 12-hour battery life and waterproof design",
        price: 79.99,
        image_url: "https://example.com/speaker.jpg"
      },
      {
        name: "Phone Case",
        description: "Protective phone case with wireless charging support and drop protection",
        price: 29.99,
        image_url: "https://example.com/phonecase.jpg"
      },
      {
        name: "Laptop Stand",
        description: "Adjustable aluminum laptop stand for better ergonomics and cooling",
        price: 49.99,
        image_url: "https://example.com/laptopstand.jpg"
      }
    ]

    products.each do |product_data|
      product = Product.find_or_create_by(name: product_data[:name]) do |p|
        p.description = product_data[:description]
        p.price = product_data[:price]
        p.image_url = product_data[:image_url]
      end
      
      if product.persisted?
        puts "✓ #{product.name} - $#{product.price}"
      else
        puts "✗ Failed to create #{product_data[:name]}: #{product.errors.full_messages.join(', ')}"
      end
    end
    
    puts "Sample products added successfully!"
  end

  desc "List all products"
  task list: :environment do
    puts "Current products in database:"
    puts "=" * 50
    
    Product.all.each do |product|
      puts "ID: #{product.id}"
      puts "Name: #{product.name}"
      puts "Price: $#{product.price}"
      puts "Description: #{product.description}"
      puts "Created: #{product.created_at.strftime('%B %d, %Y')}"
      puts "-" * 30
    end
  end

  desc "Update product prices by percentage"
  task :update_prices, [:percentage] => :environment do |t, args|
    percentage = args[:percentage].to_f
    
    if percentage == 0
      puts "Please provide a percentage (e.g., rake products:update_prices[10] for 10% increase)"
      exit
    end
    
    puts "Updating all product prices by #{percentage}%..."
    
    Product.all.each do |product|
      old_price = product.price
      new_price = old_price * (1 + percentage / 100)
      product.update!(price: new_price)
      puts "#{product.name}: $#{old_price} → $#{new_price.round(2)}"
    end
    
    puts "Price update completed!"
  end

  desc "Delete all products"
  task delete_all: :environment do
    puts "This will delete ALL products. Are you sure? (y/N)"
    response = STDIN.gets.chomp.downcase
    
    if response == 'y' || response == 'yes'
      count = Product.count
      Product.destroy_all
      puts "Deleted #{count} products."
    else
      puts "Operation cancelled."
    end
  end
end
