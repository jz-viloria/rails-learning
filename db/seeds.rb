# This file contains sample data for development
# Run with: rails db:seed

puts "🌱 Seeding database with sample products..."

# Clear existing data
Product.destroy_all
Order.destroy_all
OrderItem.destroy_all

# Create sample products
products_data = [
  {
    name: "Wireless Bluetooth Headphones",
    description: "High-quality wireless headphones with noise cancellation and 30-hour battery life. Perfect for music lovers and professionals.",
    price: 89.99,
    image_url: "https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=500",
    stock_quantity: 50,
    featured: true,
    category: "Electronics",
    brand: "SoundMax",
    sku: "WH-001"
  },
  {
    name: "Smart Fitness Watch",
    description: "Track your fitness goals with this advanced smartwatch featuring heart rate monitoring, GPS, and water resistance.",
    price: 199.99,
    image_url: "https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=500",
    stock_quantity: 25,
    featured: true,
    category: "Electronics",
    brand: "FitTech",
    sku: "SFW-002"
  },
  {
    name: "Organic Cotton T-Shirt",
    description: "Comfortable and sustainable organic cotton t-shirt. Available in multiple colors and sizes.",
    price: 24.99,
    image_url: "https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=500",
    stock_quantity: 100,
    featured: true,
    category: "Clothing",
    brand: "EcoWear",
    sku: "OCT-003"
  },
  {
    name: "Stainless Steel Water Bottle",
    description: "Keep your drinks cold for 24 hours or hot for 12 hours with this premium stainless steel water bottle.",
    price: 34.99,
    image_url: "https://images.unsplash.com/photo-1602143407151-7111542de6e8?w=500",
    stock_quantity: 75,
    featured: false,
    category: "Accessories",
    brand: "HydroMax",
    sku: "SSB-004"
  },
  {
    name: "LED Desk Lamp",
    description: "Adjustable LED desk lamp with multiple brightness levels and color temperatures. Perfect for work or study.",
    price: 45.99,
    image_url: "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=500",
    stock_quantity: 30,
    featured: false,
    category: "Home & Office",
    brand: "BrightLite",
    sku: "LDL-005"
  },
  {
    name: "Bluetooth Speaker",
    description: "Portable Bluetooth speaker with 360-degree sound and 20-hour battery life. Perfect for outdoor adventures.",
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
    description: "Premium non-slip yoga mat made from eco-friendly materials. Extra thick for comfort and support.",
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
    description: "Fast wireless charging pad compatible with all Qi-enabled devices. Sleek design with LED indicator.",
    price: 29.99,
    image_url: "https://images.unsplash.com/photo-1583394838336-acd977736f90?w=500",
    stock_quantity: 80,
    featured: false,
    category: "Electronics",
    brand: "ChargeMax",
    sku: "WPC-008"
  }
]

# Create products
products_data.each do |product_data|
  product = Product.create!(product_data)
  puts "✅ Created product: #{product.name}"
end

puts "🎉 Seeding complete!"
puts "📊 Created #{Product.count} products"
puts "🏠 Visit http://localhost:3000 to see your store!"
