#!/bin/bash

# Database setup script for Rails Dropshipping Store
# This script helps you set up PostgreSQL and run migrations

echo "🚀 Setting up database for Rails Dropshipping Store..."

# Check if PostgreSQL is installed
if ! command -v psql &> /dev/null; then
    echo "❌ PostgreSQL is not installed."
    echo "📦 Please install PostgreSQL first:"
    echo "   macOS: brew install postgresql"
    echo "   Ubuntu: sudo apt-get install postgresql postgresql-contrib"
    echo "   Windows: Download from https://www.postgresql.org/download/"
    exit 1
fi

echo "✅ PostgreSQL is installed"

# Check if PostgreSQL is running
if ! pg_isready -q; then
    echo "🔄 Starting PostgreSQL service..."
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        brew services start postgresql
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        # Linux
        sudo systemctl start postgresql
    fi
fi

echo "✅ PostgreSQL is running"

# Create databases
echo "📊 Creating databases..."
createdb dropshipping_store_development 2>/dev/null || echo "Development database already exists"
createdb dropshipping_store_test 2>/dev/null || echo "Test database already exists"

echo "✅ Databases created"

# Install gems
echo "💎 Installing gems..."
bundle install

# Run migrations
echo "🔄 Running database migrations..."
bundle exec rails db:migrate

# Seed the database
echo "🌱 Seeding database with sample data..."
bundle exec rails db:seed

echo "🎉 Database setup complete!"
echo ""
echo "📝 Next steps:"
echo "1. Start the Rails server: bundle exec rails server"
echo "2. Visit http://localhost:3000 to see your store"
echo "3. Check out the sample products we created"
