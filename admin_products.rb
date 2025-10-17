#!/usr/bin/env ruby

# Admin script to manage products in the dropshipping store
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

# Show all products
def list_products
  puts "\n📋 All Products in Store:"
  puts "=" * 80
  
  result = db_connection.exec("SELECT * FROM products ORDER BY id")
  
  result.each do |row|
    featured = row['featured'] == 't' ? '⭐' : '  '
    puts "#{featured} ID: #{row['id']} | #{row['name']}"
    puts "    Price: $#{row['price']} | Stock: #{row['stock_quantity']} | Category: #{row['category']}"
    puts "    SKU: #{row['sku']} | Brand: #{row['brand']}"
    puts "    Description: #{row['description'][0..80]}..."
    puts "-" * 80
  end
end

# Update product price
def update_price(product_id, new_price)
  result = db_connection.exec("UPDATE products SET price = $1 WHERE id = $2 RETURNING name", [new_price, product_id])
  
  if result.ntuples > 0
    puts "✅ Updated #{result[0]['name']} price to $#{new_price}"
  else
    puts "❌ Product with ID #{product_id} not found"
  end
end

# Update product stock
def update_stock(product_id, new_stock)
  result = db_connection.exec("UPDATE products SET stock_quantity = $1 WHERE id = $2 RETURNING name", [new_stock, product_id])
  
  if result.ntuples > 0
    puts "✅ Updated #{result[0]['name']} stock to #{new_stock}"
  else
    puts "❌ Product with ID #{product_id} not found"
  end
end

# Toggle featured status
def toggle_featured(product_id)
  result = db_connection.exec("UPDATE products SET featured = NOT featured WHERE id = $1 RETURNING name, featured", [product_id])
  
  if result.ntuples > 0
    featured_status = result[0]['featured'] == 't' ? 'featured' : 'not featured'
    puts "✅ #{result[0]['name']} is now #{featured_status}"
  else
    puts "❌ Product with ID #{product_id} not found"
  end
end

# Add new product
def add_product
  puts "\n➕ Add New Product:"
  print "Name: "
  name = gets.chomp
  
  print "Description: "
  description = gets.chomp
  
  print "Price: $"
  price = gets.chomp.to_f
  
  print "Stock Quantity: "
  stock_quantity = gets.chomp.to_i
  
  print "Category: "
  category = gets.chomp
  
  print "Brand: "
  brand = gets.chomp
  
  print "SKU: "
  sku = gets.chomp
  
  print "Featured? (y/n): "
  featured = gets.chomp.downcase == 'y'
  
  print "Image URL: "
  image_url = gets.chomp
  
  begin
    db_connection.exec(
      "INSERT INTO products (name, description, price, stock_quantity, category, brand, sku, featured, image_url) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)",
      [name, description, price, stock_quantity, category, brand, sku, featured, image_url]
    )
    puts "✅ Successfully added #{name} to the store!"
  rescue PG::UniqueViolation
    puts "❌ Error: SKU '#{sku}' already exists"
  rescue => e
    puts "❌ Error: #{e.message}"
  end
end

# Delete product
def delete_product(product_id)
  result = db_connection.exec("DELETE FROM products WHERE id = $1 RETURNING name", [product_id])
  
  if result.ntuples > 0
    puts "✅ Deleted #{result[0]['name']} from the store"
  else
    puts "❌ Product with ID #{product_id} not found"
  end
end

# Show menu
def show_menu
  puts "\n🛍️ Dropshipping Store Admin Panel"
  puts "=" * 40
  puts "1. List all products"
  puts "2. Update product price"
  puts "3. Update product stock"
  puts "4. Toggle featured status"
  puts "5. Add new product"
  puts "6. Delete product"
  puts "7. Exit"
  puts "=" * 40
  print "Choose an option (1-7): "
end

# Main menu loop
def main_menu
  loop do
    show_menu
    choice = gets.chomp.to_i
    
    case choice
    when 1
      list_products
    when 2
      print "Enter product ID: "
      product_id = gets.chomp.to_i
      print "Enter new price: $"
      new_price = gets.chomp.to_f
      update_price(product_id, new_price)
    when 3
      print "Enter product ID: "
      product_id = gets.chomp.to_i
      print "Enter new stock quantity: "
      new_stock = gets.chomp.to_i
      update_stock(product_id, new_stock)
    when 4
      print "Enter product ID: "
      product_id = gets.chomp.to_i
      toggle_featured(product_id)
    when 5
      add_product
    when 6
      print "Enter product ID to delete: "
      product_id = gets.chomp.to_i
      print "Are you sure? (y/n): "
      confirm = gets.chomp.downcase
      delete_product(product_id) if confirm == 'y'
    when 7
      puts "👋 Goodbye!"
      break
    else
      puts "❌ Invalid option. Please choose 1-7."
    end
  end
end

# Main execution
if __FILE__ == $0
  begin
    main_menu
  rescue => e
    puts "❌ Error: #{e.message}"
  ensure
    db_connection&.close
  end
end
