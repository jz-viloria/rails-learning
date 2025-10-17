#!/usr/bin/env ruby

# Script to add more products to the dropshipping store
require 'pg'

# Database connection
def db_connection
  @db_connection ||= PG.connect(
    host: 'localhost',
    dbname: 'dropshipping_store_development',
    user: 'postgres',
    password: 'postgres'
  )
end

# Add new products
def add_products
  puts "🛍️ Adding new products to the store..."
  
  new_products = [
    {
      name: "Bluetooth Speaker",
      description: "Portable Bluetooth speaker with 360-degree sound and 20-hour battery life. Perfect for outdoor adventures and parties.",
      price: 79.99,
      image_url: "https://images.unsplash.com/photo-1608043152269-423dbba4e7e1?w=500",
      stock_quantity: 40,
      featured: false,
      category: "Electronics",
      brand: "SoundWave",
      sku: "BTS-006"
    },
    {
      name: "Yoga Mat",
      description: "Premium non-slip yoga mat made from eco-friendly materials. Extra thick for comfort and support during your practice.",
      price: 39.99,
      image_url: "https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?w=500",
      stock_quantity: 60,
      featured: false,
      category: "Sports & Fitness",
      brand: "ZenMat",
      sku: "YM-007"
    },
    {
      name: "Wireless Phone Charger",
      description: "Fast wireless charging pad compatible with all Qi-enabled devices. Sleek design with LED indicator and safety features.",
      price: 29.99,
      image_url: "https://images.unsplash.com/photo-1583394838336-acd977736f90?w=500",
      stock_quantity: 80,
      featured: false,
      category: "Electronics",
      brand: "ChargeMax",
      sku: "WPC-008"
    },
    {
      name: "Coffee Maker",
      description: "Programmable drip coffee maker with 12-cup capacity. Features auto-shutoff, pause-and-serve, and permanent filter.",
      price: 89.99,
      image_url: "https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=500",
      stock_quantity: 25,
      featured: true,
      category: "Home & Kitchen",
      brand: "BrewMaster",
      sku: "CM-009"
    },
    {
      name: "Running Shoes",
      description: "Lightweight running shoes with responsive cushioning and breathable mesh upper. Perfect for daily runs and workouts.",
      price: 129.99,
      image_url: "https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=500",
      stock_quantity: 35,
      featured: true,
      category: "Sports & Fitness",
      brand: "RunFast",
      sku: "RS-010"
    },
    {
      name: "Laptop Stand",
      description: "Adjustable aluminum laptop stand that improves posture and reduces neck strain. Fits laptops up to 17 inches.",
      price: 49.99,
      image_url: "https://images.unsplash.com/photo-1527864550417-7fd91fc51a46?w=500",
      stock_quantity: 45,
      featured: false,
      category: "Home & Office",
      brand: "ErgoTech",
      sku: "LS-011"
    }
  ]
  
  new_products.each do |product_data|
    begin
      db_connection.exec(
        "INSERT INTO products (name, description, price, image_url, stock_quantity, featured, category, brand, sku) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)",
        [
          product_data[:name],
          product_data[:description],
          product_data[:price],
          product_data[:image_url],
          product_data[:stock_quantity],
          product_data[:featured],
          product_data[:category],
          product_data[:brand],
          product_data[:sku]
        ]
      )
      puts "✅ Added: #{product_data[:name]}"
    rescue PG::UniqueViolation
      puts "⚠️  Skipped: #{product_data[:name]} (already exists)"
    end
  end
  
  puts "\n🎉 Product addition complete!"
end

# Update existing products
def update_products
  puts "\n🔄 Updating existing products..."
  
  updates = [
    { id: 1, price: 79.99, stock_quantity: 45 },  # Headphones - reduce price and stock
    { id: 2, price: 179.99, stock_quantity: 30 }, # Smart Watch - reduce price, increase stock
    { id: 3, price: 19.99, stock_quantity: 120 }, # T-Shirt - reduce price, increase stock
  ]
  
  updates.each do |update|
    db_connection.exec(
      "UPDATE products SET price = $1, stock_quantity = $2 WHERE id = $3",
      [update[:price], update[:stock_quantity], update[:id]]
    )
    puts "✅ Updated product ID #{update[:id]}: Price $#{update[:price]}, Stock #{update[:stock_quantity]}"
  end
end

# Show current products
def show_products
  puts "\n📊 Current products in store:"
  result = db_connection.exec("SELECT id, name, price, stock_quantity, featured FROM products ORDER BY id")
  
  result.each do |row|
    featured = row['featured'] == 't' ? '⭐' : '  '
    puts "#{featured} #{row['id']}. #{row['name']} - $#{row['price']} (#{row['stock_quantity']} in stock)"
  end
end

# Main execution
if __FILE__ == $0
  begin
    add_products
    update_products
    show_products
    
    puts "\n🚀 Visit http://localhost:3000 to see your updated store!"
  rescue => e
    puts "❌ Error: #{e.message}"
  ensure
    db_connection&.close
  end
end
