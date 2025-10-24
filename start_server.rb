#!/usr/bin/env ruby

# Simple script to start a basic web server for our dropshipping store
require 'webrick'
require 'json'
require 'pg'
require 'cgi'

# Database connection
def db_connection
  @db_connection ||= begin
    # Use environment variables for Docker, fallback to localhost for development
    host = ENV['DATABASE_HOST'] || 'localhost'
    dbname = ENV['DATABASE_NAME'] || ENV['POSTGRES_DB'] || 'dropshipping_store_development'
    user = ENV['DATABASE_USER'] || ENV['POSTGRES_USER'] || 'postgres'
    password = ENV['DATABASE_PASSWORD'] || ENV['POSTGRES_PASSWORD'] || 'postgres'
    port = ENV['DATABASE_PORT'] || '5432'
    
    puts "🔌 Connecting to database: #{host}:#{port}/#{dbname} as #{user}"
    $stdout.flush
    begin
      conn = PG.connect(
        host: host,
        dbname: dbname,
        user: user,
        password: password,
        port: port
      )
      puts "✅ Database connection established!"
      $stdout.flush
    rescue => e
      puts "❌ Database connection failed: #{e.message}"
      $stdout.flush
      raise e
    end
    
    # Initialize database tables if they don't exist
    puts "🔧 Initializing database..."
    $stdout.flush
    initialize_database(conn)
    puts "✅ Database initialization complete!"
    $stdout.flush
    conn
  end
end

# Initialize database tables and sample data
def initialize_database(conn)
  begin
    # Create tables
    conn.exec("
      CREATE TABLE IF NOT EXISTS products (
        id SERIAL PRIMARY KEY,
        name VARCHAR(255) NOT NULL,
        description TEXT,
        price DECIMAL(10,2) NOT NULL,
        image_url VARCHAR(255),
        stock_quantity INTEGER DEFAULT 0,
        featured BOOLEAN DEFAULT FALSE,
        category VARCHAR(100),
        brand VARCHAR(100),
        sku VARCHAR(50),
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );
    ")
    
    conn.exec("
      CREATE TABLE IF NOT EXISTS orders (
        id SERIAL PRIMARY KEY,
        user_id INTEGER,
        status VARCHAR(50) DEFAULT 'pending',
        total_amount DECIMAL(10,2),
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );
    ")
    
    conn.exec("
      CREATE TABLE IF NOT EXISTS order_items (
        id SERIAL PRIMARY KEY,
        order_id INTEGER NOT NULL,
        product_id INTEGER NOT NULL,
        quantity INTEGER NOT NULL DEFAULT 1,
        price DECIMAL(10,2) NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (order_id) REFERENCES orders(id),
        FOREIGN KEY (product_id) REFERENCES products(id)
      );
    ")
    
    conn.exec("
      CREATE TABLE IF NOT EXISTS users (
        id SERIAL PRIMARY KEY,
        first_name VARCHAR(255) NOT NULL,
        last_name VARCHAR(255) NOT NULL,
        email VARCHAR(255) NOT NULL UNIQUE,
        password_digest VARCHAR(255) NOT NULL,
        address_line1 VARCHAR(255),
        address_line2 VARCHAR(255),
        city VARCHAR(255),
        state VARCHAR(255),
        zip_code VARCHAR(20),
        country VARCHAR(50) DEFAULT 'US',
        preferences JSONB DEFAULT '{}',
        admin BOOLEAN DEFAULT FALSE,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );
    ")
    
    # Add sample products if none exist
    result = conn.exec("SELECT COUNT(*) FROM products")
    if result[0]['count'].to_i == 0
      sample_products = [
        {
          name: "Wireless Bluetooth Headphones",
          description: "High-quality wireless headphones with noise cancellation and 30-hour battery life.",
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
          description: "Track your fitness goals with this advanced smartwatch featuring heart rate monitoring.",
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
          description: "Comfortable and sustainable organic cotton t-shirt. Available in multiple colors.",
          price: 24.99,
          image_url: "https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=500",
          stock_quantity: 100,
          featured: true,
          category: "Clothing",
          brand: "EcoWear",
          sku: "OCT-003"
        }
      ]
      
      sample_products.each do |product|
        conn.exec_params("
          INSERT INTO products (name, description, price, image_url, stock_quantity, featured, category, brand, sku)
          VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)
        ", [
          product[:name], product[:description], product[:price], product[:image_url],
          product[:stock_quantity], product[:featured], product[:category], product[:brand], product[:sku]
        ])
      end
      
      puts "✅ Added #{sample_products.length} sample products to the database"
    end
    
  rescue => e
    puts "⚠️ Database initialization warning: #{e.message}"
  end
end

# Get all products
def get_products
  puts "🛍️ Getting products from database..."
  $stdout.flush
  result = db_connection.exec("SELECT * FROM products ORDER BY created_at DESC")
  result.map do |row|
    {
      id: row['id'],
      name: row['name'],
      description: row['description'],
      price: row['price'],
      image_url: row['image_url'],
      stock_quantity: row['stock_quantity'],
      featured: row['featured'] == 't',
      category: row['category'],
      brand: row['brand'],
      sku: row['sku']
    }
  end
end

# Get a single product
def get_product(id)
  result = db_connection.exec("SELECT * FROM products WHERE id = $1", [id])
  return nil if result.ntuples == 0
  
  row = result[0]
  {
    id: row['id'],
    name: row['name'],
    description: row['description'],
    price: row['price'],
    image_url: row['image_url'],
    stock_quantity: row['stock_quantity'],
    featured: row['featured'] == 't',
    category: row['category'],
    brand: row['brand'],
    sku: row['sku']
  }
end

# Shopping cart management
def get_cart_from_cookie(cookie_string)
  return {} unless cookie_string
  
  cart_cookie = cookie_string.split(';').find { |c| c.strip.start_with?('cart=') }
  return {} unless cart_cookie
  
  cart_data = cart_cookie.split('=', 2)[1]
  return {} unless cart_data
  
  begin
    JSON.parse(CGI.unescape(cart_data))
  rescue
    {}
  end
end

def cart_to_cookie(cart)
  "cart=#{CGI.escape(cart.to_json)}; Path=/; Max-Age=86400"
end

def add_to_cart(cart, product_id, quantity = 1)
  product_id = product_id.to_s
  cart[product_id] = (cart[product_id] || 0) + quantity.to_i
  cart
end

def remove_from_cart(cart, product_id)
  cart.delete(product_id.to_s)
  cart
end

def update_cart_item(cart, product_id, quantity)
  product_id = product_id.to_s
  if quantity.to_i <= 0
    cart.delete(product_id)
  else
    cart[product_id] = quantity.to_i
  end
  cart
end

def get_cart_items(cart)
  return [] if cart.empty?
  
  product_ids = cart.keys.join(',')
  result = db_connection.exec("SELECT * FROM products WHERE id IN (#{product_ids})")
  
  result.map do |row|
    product = {
      id: row['id'],
      name: row['name'],
      description: row['description'],
      price: row['price'].to_f,
      image_url: row['image_url'],
      stock_quantity: row['stock_quantity'].to_i,
      featured: row['featured'] == 't',
      category: row['category'],
      brand: row['brand'],
      sku: row['sku']
    }
    
    quantity = cart[row['id']].to_i
    {
      product: product,
      quantity: quantity,
      total_price: product[:price] * quantity
    }
  end
end

def get_cart_total(cart_items)
  cart_items.sum { |item| item[:total_price] }
end

# User authentication helpers
def get_user_from_session(cookie_string)
  return nil unless cookie_string
  
  session_cookie = cookie_string.split(';').find { |c| c.strip.start_with?('user_session=') }
  return nil unless session_cookie
  
  session_data = session_cookie.split('=', 2)[1]
  return nil unless session_data
  
  begin
    JSON.parse(CGI.unescape(session_data))['user_id']
  rescue
    nil
  end
end

def session_to_cookie(user_id)
  session_data = { user_id: user_id }
  "user_session=#{CGI.escape(session_data.to_json)}; Path=/; Max-Age=86400"
end

def get_user(user_id)
  result = db_connection.exec("SELECT * FROM users WHERE id = $1", [user_id])
  return nil if result.ntuples == 0
  
  row = result[0]
  {
    id: row['id'],
    first_name: row['first_name'],
    last_name: row['last_name'],
    email: row['email'],
    phone: row['phone'],
    address_line1: row['address_line1'],
    address_line2: row['address_line2'],
    city: row['city'],
    state: row['state'],
    zip_code: row['zip_code'],
    country: row['country'],
    email_notifications: row['email_notifications'] == 't',
    sms_notifications: row['sms_notifications'] == 't',
    active: row['active'] == 't',
    last_login_at: row['last_login_at'],
    created_at: row['created_at']
  }
end

def get_user_orders(user_id)
  result = db_connection.exec("SELECT * FROM orders WHERE user_id = $1 ORDER BY created_at DESC LIMIT 5", [user_id])
  
  result.map do |row|
    {
      id: row['id'],
      customer_name: row['customer_name'],
      customer_email: row['customer_email'],
      total_amount: row['total_amount'].to_f,
      status: row['status'],
      created_at: row['created_at']
    }
  end
end

def parse_form_data(body)
  form_data = {}
  body.split('&').each do |pair|
    key, value = pair.split('=', 2)
    form_data[CGI.unescape(key)] = CGI.unescape(value || '')
  end
  form_data
end

# HTML template for the homepage
def homepage_html(cart = {})
  products = get_products
  featured_products = products.select { |p| p[:featured] }
  cart_items = get_cart_items(cart)
  cart_count = cart_items.sum { |item| item[:quantity] }
  
  <<~HTML
    <!DOCTYPE html>
    <html>
    <head>
      <title>Dropshipping Store</title>
      <meta name="viewport" content="width=device-width,initial-scale=1">
      <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    </head>
    <body>
      <nav class="navbar navbar-expand-lg navbar-dark bg-dark">
        <div class="container">
          <a class="navbar-brand" href="/">Dropshipping Store</a>
          <div class="navbar-nav ms-auto">
            <a class="nav-link" href="/products">Products</a>
            <a class="nav-link" href="/about">About</a>
            <a class="nav-link position-relative" href="/cart">
              🛒 Cart
              #{if cart_count > 0
                "<span class='position-absolute top-0 start-100 translate-middle badge rounded-pill bg-danger'>#{cart_count}</span>"
              end}
            </a>
          </div>
        </div>
      </nav>

      <main class="container mt-4">
        <div class="row">
          <div class="col-12">
            <h1 class="display-4 text-center mb-5">Welcome to Our Dropshipping Store!</h1>
            
            #{if featured_products.any?
              <<~FEATURED
                <div class="mb-5">
                  <h2 class="text-center mb-4">Featured Products</h2>
                  <div class="row">
                    #{featured_products.map do |product|
                      <<~PRODUCT
                        <div class="col-md-4 mb-4">
                          <div class="card h-100">
                            <img src="#{product[:image_url]}" class="card-img-top" style="height: 200px; object-fit: cover;" alt="#{product[:name]}">
                            <div class="card-body d-flex flex-column">
                              <h5 class="card-title">#{product[:name]}</h5>
                              <p class="card-text flex-grow-1">#{product[:description][0..100]}...</p>
                              <div class="mt-auto">
                                <p class="card-text">
                                  <strong class="text-success">$#{product[:price]}</strong>
                                  #{'<span class="badge bg-warning text-dark ms-2">Low Stock</span>' if product[:stock_quantity].to_i < 10}
                                </p>
                                <a href="/products/#{product[:id]}" class="btn btn-primary">View Details</a>
                                <a href="/cart/add/#{product[:id]}" class="btn btn-success ms-2">Add to Cart</a>
                              </div>
                            </div>
                          </div>
                        </div>
                      PRODUCT
                    end.join}
                  </div>
                </div>
              FEATURED
            end}

            <div class="mb-5">
              <h2 class="text-center mb-4">All Products</h2>
              <div class="row">
                #{products.map do |product|
                  <<~PRODUCT
                    <div class="col-lg-3 col-md-4 col-sm-6 mb-4">
                      <div class="card h-100">
                        <img src="#{product[:image_url]}" class="card-img-top" style="height: 150px; object-fit: cover;" alt="#{product[:name]}">
                        <div class="card-body d-flex flex-column">
                          <h6 class="card-title">#{product[:name]}</h6>
                          <p class="card-text flex-grow-1 small">#{product[:description][0..80]}...</p>
                          <div class="mt-auto">
                            <p class="card-text">
                              <strong class="text-success">$#{product[:price]}</strong>
                              #{'<span class="badge bg-danger ms-2">Out of Stock</span>' if product[:stock_quantity].to_i == 0}
                            </p>
                            <a href="/products/#{product[:id]}" class="btn btn-outline-primary btn-sm">View</a>
                          </div>
                        </div>
                      </div>
                    </div>
                  PRODUCT
                end.join}
              </div>
            </div>
          </div>
        </div>
      </main>

      <footer class="bg-dark text-light text-center py-3 mt-5">
        <div class="container">
          <p>&copy; 2024 Dropshipping Store. Built with Ruby on Rails.</p>
        </div>
      </footer>

      <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
    </body>
    </html>
  HTML
end

# HTML template for product show page
def product_show_html(product, cart = {})
  return "Product not found" unless product
  
  cart_items = get_cart_items(cart)
  cart_count = cart_items.sum { |item| item[:quantity] }
  
  <<~HTML
    <!DOCTYPE html>
    <html>
    <head>
      <title>#{product[:name]} - Dropshipping Store</title>
      <meta name="viewport" content="width=device-width,initial-scale=1">
      <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    </head>
    <body>
      <nav class="navbar navbar-expand-lg navbar-dark bg-dark">
        <div class="container">
          <a class="navbar-brand" href="/">Dropshipping Store</a>
          <div class="navbar-nav ms-auto">
            <a class="nav-link" href="/products">Products</a>
            <a class="nav-link" href="/about">About</a>
            <a class="nav-link position-relative" href="/cart">
              🛒 Cart
              #{if cart_count > 0
                "<span class='position-absolute top-0 start-100 translate-middle badge rounded-pill bg-danger'>#{cart_count}</span>"
              end}
            </a>
          </div>
        </div>
      </nav>

      <main class="container mt-4">
        <div class="row">
          <div class="col-md-6">
            <img src="#{product[:image_url]}" class="img-fluid rounded" alt="#{product[:name]}">
          </div>
          
          <div class="col-md-6">
            <h1 class="display-5">#{product[:name]}</h1>
            
            <div class="mb-3">
              <span class="h3 text-success">$#{product[:price]}</span>
              #{'<span class="badge bg-warning text-dark ms-2">Low Stock</span>' if product[:stock_quantity].to_i < 10}
              #{'<span class="badge bg-danger ms-2">Out of Stock</span>' if product[:stock_quantity].to_i == 0}
            </div>
            
            <p class="lead">#{product[:description]}</p>
            
            <div class="mb-4">
              <h5>Stock Status</h5>
              <p>
                #{if product[:stock_quantity].to_i > 0
                  "<span class='text-success'>✓ In Stock</span> (#{product[:stock_quantity]} available)"
                else
                  "<span class='text-danger'>✗ Out of Stock</span>"
                end}
              </p>
            </div>
            
            <div class="d-grid gap-2 d-md-flex">
              #{if product[:stock_quantity].to_i > 0
                "<a href='/cart/add/#{product[:id]}' class='btn btn-success btn-lg'>Add to Cart</a>"
              else
                '<button class="btn btn-secondary btn-lg" disabled>Out of Stock</button>'
              end}
              <a href="/" class="btn btn-outline-secondary">Back to Products</a>
            </div>
          </div>
        </div>

        <div class="row mt-5">
          <div class="col-12">
            <h3>Product Details</h3>
            <table class="table table-striped">
              <tr><td><strong>Name:</strong></td><td>#{product[:name]}</td></tr>
              <tr><td><strong>Price:</strong></td><td>$#{product[:price]}</td></tr>
              <tr><td><strong>Stock Quantity:</strong></td><td>#{product[:stock_quantity]}</td></tr>
              <tr><td><strong>Category:</strong></td><td>#{product[:category]}</td></tr>
              <tr><td><strong>Brand:</strong></td><td>#{product[:brand]}</td></tr>
              <tr><td><strong>SKU:</strong></td><td>#{product[:sku]}</td></tr>
              <tr><td><strong>Featured:</strong></td><td>#{product[:featured] ? 'Yes' : 'No'}</td></tr>
            </table>
          </div>
        </div>
      </main>

      <footer class="bg-dark text-light text-center py-3 mt-5">
        <div class="container">
          <p>&copy; 2024 Dropshipping Store. Built with Ruby on Rails.</p>
        </div>
      </footer>

      <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
    </body>
    </html>
  HTML
end

# Cart page HTML
def cart_html(cart = {})
  cart_items = get_cart_items(cart)
  cart_total = get_cart_total(cart_items)
  cart_count = cart_items.sum { |item| item[:quantity] }
  
  <<~HTML
    <!DOCTYPE html>
    <html>
    <head>
      <title>Shopping Cart - Dropshipping Store</title>
      <meta name="viewport" content="width=device-width,initial-scale=1">
      <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    </head>
    <body>
      <nav class="navbar navbar-expand-lg navbar-dark bg-dark">
        <div class="container">
          <a class="navbar-brand" href="/">Dropshipping Store</a>
          <div class="navbar-nav ms-auto">
            <a class="nav-link" href="/products">Products</a>
            <a class="nav-link" href="/about">About</a>
            <a class="nav-link position-relative" href="/cart">
              🛒 Cart
              #{if cart_count > 0
                "<span class='position-absolute top-0 start-100 translate-middle badge rounded-pill bg-danger'>#{cart_count}</span>"
              end}
            </a>
          </div>
        </div>
      </nav>

      <main class="container mt-4">
        <div class="row">
          <div class="col-12">
            <h1 class="display-4 text-center mb-5">Shopping Cart</h1>
            
            #{if cart_items.empty?
              <<~EMPTY
                <div class="text-center">
                  <h3>Your cart is empty</h3>
                  <p class="lead">Add some products to get started!</p>
                  <a href="/" class="btn btn-primary btn-lg">Continue Shopping</a>
                </div>
              EMPTY
            else
              <<~CART
                <div class="row">
                  <div class="col-lg-8">
                    #{cart_items.map do |item|
                      <<~ITEM
                        <div class="card mb-3">
                          <div class="card-body">
                            <div class="row">
                              <div class="col-md-3">
                                <img src="#{item[:product][:image_url]}" class="img-fluid rounded" alt="#{item[:product][:name]}">
                              </div>
                              <div class="col-md-6">
                                <h5 class="card-title">#{item[:product][:name]}</h5>
                                <p class="card-text">#{item[:product][:description][0..100]}...</p>
                                <p class="card-text">
                                  <small class="text-muted">SKU: #{item[:product][:sku]}</small>
                                </p>
                              </div>
                              <div class="col-md-3 text-end">
                                <p class="h5">$#{item[:product][:price]}</p>
                                <div class="input-group mb-2" style="width: 120px; margin-left: auto;">
                                  <a href="/cart/update/#{item[:product][:id]}/#{item[:quantity] - 1}" class="btn btn-outline-secondary btn-sm">-</a>
                                  <input type="text" class="form-control text-center" value="#{item[:quantity]}" readonly>
                                  <a href="/cart/update/#{item[:product][:id]}/#{item[:quantity] + 1}" class="btn btn-outline-secondary btn-sm">+</a>
                                </div>
                                <p class="h6 text-success">Total: $#{item[:total_price].round(2)}</p>
                                <a href="/cart/remove/#{item[:product][:id]}" class="btn btn-outline-danger btn-sm">Remove</a>
                              </div>
                            </div>
                          </div>
                        </div>
                      ITEM
                    end.join}
                  </div>
                  
                  <div class="col-lg-4">
                    <div class="card">
                      <div class="card-header">
                        <h5>Order Summary</h5>
                      </div>
                      <div class="card-body">
                        <div class="d-flex justify-content-between">
                          <span>Subtotal (#{cart_count} items):</span>
                          <span>$#{cart_total.round(2)}</span>
                        </div>
                        <div class="d-flex justify-content-between">
                          <span>Shipping:</span>
                          <span>Free</span>
                        </div>
                        <hr>
                        <div class="d-flex justify-content-between">
                          <strong>Total:</strong>
                          <strong>$#{cart_total.round(2)}</strong>
                        </div>
                        <div class="d-grid gap-2 mt-3">
                          <button class="btn btn-success btn-lg" disabled>Checkout (Coming Soon)</button>
                          <a href="/" class="btn btn-outline-primary">Continue Shopping</a>
                        </div>
                      </div>
                    </div>
                  </div>
                </div>
              CART
            end}
          </div>
        </div>
      </main>

      <footer class="bg-dark text-light text-center py-3 mt-5">
        <div class="container">
          <p>&copy; 2024 Dropshipping Store. Built with Ruby on Rails.</p>
        </div>
      </footer>

      <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
    </body>
    </html>
  HTML
end

# Registration page HTML
def registration_html
  <<~HTML
    <!DOCTYPE html>
    <html>
    <head>
      <title>Create Account - Dropshipping Store</title>
      <meta name="viewport" content="width=device-width,initial-scale=1">
      <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    </head>
    <body>
      <nav class="navbar navbar-expand-lg navbar-dark bg-dark">
        <div class="container">
          <a class="navbar-brand" href="/">Dropshipping Store</a>
          <div class="navbar-nav ms-auto">
            <a class="nav-link" href="/products">Products</a>
            <a class="nav-link" href="/about">About</a>
            <a class="nav-link" href="/login">Sign In</a>
          </div>
        </div>
      </nav>

      <main class="container mt-4">
        <div class="row justify-content-center">
          <div class="col-md-6">
            <div class="card">
              <div class="card-header">
                <h2 class="text-center mb-0">Create Account</h2>
              </div>
              <div class="card-body">
                <form action="/register" method="post">
                  <div class="row">
                    <div class="col-md-6">
                      <div class="mb-3">
                        <label for="first_name" class="form-label">First Name</label>
                        <input type="text" class="form-control" id="first_name" name="first_name" required>
                      </div>
                    </div>
                    <div class="col-md-6">
                      <div class="mb-3">
                        <label for="last_name" class="form-label">Last Name</label>
                        <input type="text" class="form-control" id="last_name" name="last_name" required>
                      </div>
                    </div>
                  </div>

                  <div class="mb-3">
                    <label for="email" class="form-label">Email</label>
                    <input type="email" class="form-control" id="email" name="email" required>
                  </div>

                  <div class="mb-3">
                    <label for="phone" class="form-label">Phone</label>
                    <input type="tel" class="form-control" id="phone" name="phone">
                  </div>

                  <div class="mb-3">
                    <label for="password" class="form-label">Password</label>
                    <input type="password" class="form-control" id="password" name="password" required minlength="6">
                  </div>

                  <div class="d-grid">
                    <button type="submit" class="btn btn-primary btn-lg">Create Account</button>
                  </div>
                </form>

                <hr class="my-4">
                <div class="text-center">
                  <p class="mb-0">Already have an account?</p>
                  <a href="/login" class="btn btn-outline-secondary">Sign In</a>
                </div>
              </div>
            </div>
          </div>
        </div>
      </main>

      <footer class="bg-dark text-light text-center py-3 mt-5">
        <div class="container">
          <p>&copy; 2024 Dropshipping Store. Built with Ruby on Rails.</p>
        </div>
      </footer>

      <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
    </body>
    </html>
  HTML
end

# Login page HTML
def login_html
  <<~HTML
    <!DOCTYPE html>
    <html>
    <head>
      <title>Sign In - Dropshipping Store</title>
      <meta name="viewport" content="width=device-width,initial-scale=1">
      <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    </head>
    <body>
      <nav class="navbar navbar-expand-lg navbar-dark bg-dark">
        <div class="container">
          <a class="navbar-brand" href="/">Dropshipping Store</a>
          <div class="navbar-nav ms-auto">
            <a class="nav-link" href="/products">Products</a>
            <a class="nav-link" href="/about">About</a>
            <a class="nav-link" href="/register">Register</a>
          </div>
        </div>
      </nav>

      <main class="container mt-4">
        <div class="row justify-content-center">
          <div class="col-md-4">
            <div class="card">
              <div class="card-header">
                <h2 class="text-center mb-0">Sign In</h2>
              </div>
              <div class="card-body">
                <form action="/login" method="post">
                  <div class="mb-3">
                    <label for="email" class="form-label">Email</label>
                    <input type="email" class="form-control" id="email" name="email" required>
                  </div>

                  <div class="mb-3">
                    <label for="password" class="form-label">Password</label>
                    <input type="password" class="form-control" id="password" name="password" required>
                  </div>

                  <div class="d-grid">
                    <button type="submit" class="btn btn-primary btn-lg">Sign In</button>
                  </div>
                </form>

                <hr class="my-4">
                <div class="text-center">
                  <p class="mb-0">Don't have an account?</p>
                  <a href="/register" class="btn btn-outline-secondary">Create Account</a>
                </div>
              </div>
            </div>
          </div>
        </div>
      </main>

      <footer class="bg-dark text-light text-center py-3 mt-5">
        <div class="container">
          <p>&copy; 2024 Dropshipping Store. Built with Ruby on Rails.</p>
        </div>
      </footer>

      <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
    </body>
    </html>
  HTML
end

# Dashboard page HTML
def dashboard_html(user)
  orders = get_user_orders(user[:id])
  total_spent = orders.sum { |order| order[:total_amount] }
  
  <<~HTML
    <!DOCTYPE html>
    <html>
    <head>
      <title>Dashboard - Dropshipping Store</title>
      <meta name="viewport" content="width=device-width,initial-scale=1">
      <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    </head>
    <body>
      <nav class="navbar navbar-expand-lg navbar-dark bg-dark">
        <div class="container">
          <a class="navbar-brand" href="/">Dropshipping Store</a>
          <div class="navbar-nav ms-auto">
            <a class="nav-link" href="/products">Products</a>
            <a class="nav-link" href="/about">About</a>
            <div class="nav-item dropdown">
              <a class="nav-link dropdown-toggle" href="#" role="button" data-bs-toggle="dropdown">
                #{user[:first_name]}
              </a>
              <ul class="dropdown-menu">
                <li><a class="dropdown-item" href="/dashboard">Dashboard</a></li>
                <li><hr class="dropdown-divider"></li>
                <li><a class="dropdown-item" href="/logout">Sign Out</a></li>
              </ul>
            </div>
          </div>
        </div>
      </nav>

      <main class="container mt-4">
        <div class="row">
          <div class="col-12">
            <div class="d-flex justify-content-between align-items-center mb-4">
              <h1>Welcome back, #{user[:first_name]}!</h1>
              <a href="/logout" class="btn btn-outline-danger">Sign Out</a>
            </div>

            <!-- User Stats -->
            <div class="row mb-4">
              <div class="col-md-3">
                <div class="card text-center">
                  <div class="card-body">
                    <h5 class="card-title text-primary">#{orders.length}</h5>
                    <p class="card-text">Total Orders</p>
                  </div>
                </div>
              </div>
              <div class="col-md-3">
                <div class="card text-center">
                  <div class="card-body">
                    <h5 class="card-title text-success">$#{sprintf('%.2f', total_spent)}</h5>
                    <p class="card-text">Total Spent</p>
                  </div>
                </div>
              </div>
              <div class="col-md-3">
                <div class="card text-center">
                  <div class="card-body">
                    <h5 class="card-title text-info">
                      #{user[:last_login_at] ? Time.parse(user[:last_login_at]).strftime('%m/%d/%Y') : 'First time!'}
                    </h5>
                    <p class="card-text">Last Login</p>
                  </div>
                </div>
              </div>
              <div class="col-md-3">
                <div class="card text-center">
                  <div class="card-body">
                    <h5 class="card-title text-warning">
                      #{Time.parse(user[:created_at]).strftime('%m/%d/%Y')}
                    </h5>
                    <p class="card-text">Member Since</p>
                  </div>
                </div>
              </div>
            </div>

            <div class="row">
              <!-- Recent Orders -->
              <div class="col-lg-8">
                <div class="card">
                  <div class="card-header">
                    <h5 class="mb-0">Recent Orders</h5>
                  </div>
                  <div class="card-body">
                    #{if orders.any?
                      <<~ORDERS
                        <div class="table-responsive">
                          <table class="table table-hover">
                            <thead>
                              <tr>
                                <th>Order #</th>
                                <th>Date</th>
                                <th>Status</th>
                                <th>Total</th>
                              </tr>
                            </thead>
                            <tbody>
                              #{orders.map do |order|
                                <<~ORDER_ROW
                                  <tr>
                                    <td>##{order[:id]}</td>
                                    <td>#{Time.parse(order[:created_at]).strftime('%m/%d/%Y')}</td>
                                    <td>
                                      <span class="badge bg-#{case order[:status]
                                        when 'pending' then 'warning'
                                        when 'processing' then 'info'
                                        when 'shipped' then 'primary'
                                        when 'delivered' then 'success'
                                        when 'cancelled' then 'danger'
                                        else 'secondary'
                                      end}">
                                        #{order[:status].titleize}
                                      </span>
                                    </td>
                                    <td>$#{sprintf('%.2f', order[:total_amount])}</td>
                                  </tr>
                                ORDER_ROW
                              end.join}
                            </tbody>
                          </table>
                        </div>
                      ORDERS
                    else
                      <<~NO_ORDERS
                        <div class="text-center py-4">
                          <p class="text-muted">No orders yet. Start shopping!</p>
                          <a href="/" class="btn btn-primary">Browse Products</a>
                        </div>
                      NO_ORDERS
                    end}
                  </div>
                </div>
              </div>

              <!-- Account Information -->
              <div class="col-lg-4">
                <div class="card">
                  <div class="card-header">
                    <h5 class="mb-0">Account Information</h5>
                  </div>
                  <div class="card-body">
                    <h6>Contact Information</h6>
                    <p class="mb-2">
                      <strong>Name:</strong> #{user[:first_name]} #{user[:last_name]}<br>
                      <strong>Email:</strong> #{user[:email]}<br>
                      #{user[:phone] ? "<strong>Phone:</strong> #{user[:phone]}<br>" : ''}
                    </p>

                    <div class="d-grid gap-2 mt-3">
                      <a href="/" class="btn btn-primary">Browse Products</a>
                      <a href="/cart" class="btn btn-outline-primary">View Cart</a>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </main>

      <footer class="bg-dark text-light text-center py-3 mt-5">
        <div class="container">
          <p>&copy; 2024 Dropshipping Store. Built with Ruby on Rails.</p>
        </div>
      </footer>

      <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
    </body>
    </html>
  HTML
end

# About page HTML
def about_html
  <<~HTML
    <!DOCTYPE html>
    <html>
    <head>
      <title>About - Dropshipping Store</title>
      <meta name="viewport" content="width=device-width,initial-scale=1">
      <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    </head>
    <body>
      <nav class="navbar navbar-expand-lg navbar-dark bg-dark">
        <div class="container">
          <a class="navbar-brand" href="/">Dropshipping Store</a>
          <div class="navbar-nav ms-auto">
            <a class="nav-link" href="/products">Products</a>
            <a class="nav-link" href="/about">About</a>
          </div>
        </div>
      </nav>

      <main class="container mt-4">
        <div class="row">
          <div class="col-lg-8 mx-auto">
            <h1 class="display-4 text-center mb-5">About Our Store</h1>
            
            <div class="card">
              <div class="card-body">
                <h2 class="card-title">Welcome to Our Dropshipping Store!</h2>
                <p class="lead">
                  We're passionate about bringing you high-quality products at affordable prices. 
                  Our dropshipping model allows us to offer a wide variety of items without the 
                  overhead of maintaining inventory.
                </p>
                
                <h3>What is Dropshipping?</h3>
                <p>
                  Dropshipping is a retail fulfillment method where we don't keep the products 
                  we sell in stock. Instead, when a customer places an order, we purchase the 
                  item from a third party and have it shipped directly to the customer.
                </p>
                
                <h3>Why Choose Us?</h3>
                <ul class="list-unstyled">
                  <li class="mb-2">✅ <strong>Quality Products:</strong> We carefully curate our selection</li>
                  <li class="mb-2">✅ <strong>Fast Shipping:</strong> Direct from suppliers to you</li>
                  <li class="mb-2">✅ <strong>Great Prices:</strong> No middleman markup</li>
                  <li class="mb-2">✅ <strong>Customer Service:</strong> We're here to help</li>
                </ul>
                
                <div class="text-center mt-4">
                  <a href="/" class="btn btn-primary btn-lg">Browse Products</a>
                </div>
              </div>
            </div>
          </div>
        </div>
      </main>

      <footer class="bg-dark text-light text-center py-3 mt-5">
        <div class="container">
          <p>&copy; 2024 Dropshipping Store. Built with Ruby on Rails.</p>
        </div>
      </footer>

      <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
    </body>
    </html>
  HTML
end

# Create the server
server = WEBrick::HTTPServer.new(Port: 3000)

# Route handlers
server.mount_proc '/' do |req, res|
  cart = get_cart_from_cookie(req['Cookie'])
  res.content_type = 'text/html'
  res.body = homepage_html(cart)
end

server.mount_proc '/products' do |req, res|
  cart = get_cart_from_cookie(req['Cookie'])
  res.content_type = 'text/html'
  res.body = homepage_html(cart)
end

server.mount_proc '/products/' do |req, res|
  product_id = req.path.split('/').last
  product = get_product(product_id)
  cart = get_cart_from_cookie(req['Cookie'])
  res.content_type = 'text/html'
  res.body = product_show_html(product, cart)
end

server.mount_proc '/cart' do |req, res|
  cart = get_cart_from_cookie(req['Cookie'])
  res.content_type = 'text/html'
  res.body = cart_html(cart)
end

server.mount_proc '/cart/add/' do |req, res|
  product_id = req.path.split('/').last
  cart = get_cart_from_cookie(req['Cookie'])
  cart = add_to_cart(cart, product_id)
  
  res['Set-Cookie'] = cart_to_cookie(cart)
  res.status = 302
  res['Location'] = '/cart'
end

server.mount_proc '/cart/update/' do |req, res|
  parts = req.path.split('/')
  product_id = parts[3]
  quantity = parts[4].to_i
  cart = get_cart_from_cookie(req['Cookie'])
  cart = update_cart_item(cart, product_id, quantity)
  
  res['Set-Cookie'] = cart_to_cookie(cart)
  res.status = 302
  res['Location'] = '/cart'
end

server.mount_proc '/cart/remove/' do |req, res|
  product_id = req.path.split('/').last
  cart = get_cart_from_cookie(req['Cookie'])
  cart = remove_from_cart(cart, product_id)
  
  res['Set-Cookie'] = cart_to_cookie(cart)
  res.status = 302
  res['Location'] = '/cart'
end

server.mount_proc '/about' do |req, res|
  res.content_type = 'text/html'
  res.body = about_html
end

# Authentication routes
server.mount_proc '/register' do |req, res|
  res.content_type = 'text/html'
  res.body = registration_html
end

server.mount_proc '/login' do |req, res|
  res.content_type = 'text/html'
  res.body = login_html
end

server.mount_proc '/dashboard' do |req, res|
  user_id = get_user_from_session(req['Cookie'])
  if user_id
    user = get_user(user_id)
    res.content_type = 'text/html'
    res.body = dashboard_html(user)
  else
    res.status = 302
    res['Location'] = '/login'
  end
end

# POST handlers for authentication
server.mount_proc '/register' do |req, res|
  if req.request_method == 'POST'
    # Parse form data
    form_data = parse_form_data(req.body.read)
    
    # Create user (simplified - no password hashing for demo)
    begin
      result = db_connection.exec(
        "INSERT INTO users (first_name, last_name, email, phone, password_digest, created_at, updated_at) VALUES ($1, $2, $3, $4, $5, NOW(), NOW()) RETURNING id",
        [form_data['first_name'], form_data['last_name'], form_data['email'], form_data['phone'], form_data['password']]
      )
      
      user_id = result[0]['id']
      res['Set-Cookie'] = session_to_cookie(user_id)
      res.status = 302
      res['Location'] = '/dashboard'
    rescue PG::UniqueViolation
      res.content_type = 'text/html'
      res.body = registration_html + "<script>alert('Email already exists!');</script>"
    end
  else
    res.content_type = 'text/html'
    res.body = registration_html
  end
end

server.mount_proc '/login' do |req, res|
  if req.request_method == 'POST'
    # Parse form data
    form_data = parse_form_data(req.body.read)
    
    # Find user and check password (simplified - no hashing for demo)
    result = db_connection.exec(
      "SELECT id FROM users WHERE email = $1 AND password_digest = $2",
      [form_data['email'], form_data['password']]
    )
    
    if result.ntuples > 0
      user_id = result[0]['id']
      # Update last login
      db_connection.exec("UPDATE users SET last_login_at = NOW() WHERE id = $1", [user_id])
      
      res['Set-Cookie'] = session_to_cookie(user_id)
      res.status = 302
      res['Location'] = '/dashboard'
    else
      res.content_type = 'text/html'
      res.body = login_html + "<script>alert('Invalid email or password!');</script>"
    end
  else
    res.content_type = 'text/html'
    res.body = login_html
  end
end

server.mount_proc '/logout' do |req, res|
  res['Set-Cookie'] = 'user_session=; Path=/; Max-Age=0'
  res.status = 302
  res['Location'] = '/'
end

# Handle shutdown gracefully
trap 'INT' do
  server.shutdown
end

puts "🚀 Starting Dropshipping Store server on http://localhost:3000"
puts "📱 Visit http://localhost:3000 to see your store!"
puts "🛑 Press Ctrl+C to stop the server"

server.start
