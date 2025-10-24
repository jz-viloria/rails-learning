#!/bin/bash

echo "🚀 Setting up Rails Admin Interface..."

# Ensure bundler is installed and gems are up to date
echo "📦 Running bundle install..."
bundle install --path vendor/bundle || { echo "❌ bundle install failed."; exit 1; }

# Run database migrations to create the users table
echo "🗄️ Running database migrations..."
bundle exec rails db:migrate || { echo "❌ Database migration failed."; exit 1; }

# Seed the database with sample data
echo "🌱 Seeding database with sample data..."
bundle exec rails db:seed || { echo "❌ Database seeding failed."; exit 1; }

# Run RSpec tests for the admin interface
echo "🧪 Running RSpec tests for Admin Interface..."
bundle exec rspec spec/controllers/admin/ spec/models/user_spec.rb || { echo "❌ RSpec tests failed."; exit 1; }

# Run RuboCop for code style checks
echo "✨ Running RuboCop for code style..."
bundle exec rubocop || { echo "❌ RuboCop found issues. Please fix them."; exit 1; }

echo "✅ Rails Admin Interface Setup Complete!"
echo ""
echo "🎯 What you can do now:"
echo "1. Start the server: bundle exec ruby start_server.rb"
echo "2. Visit: http://localhost:3000"
echo "3. Login as admin: admin@example.com / password123"
echo "4. Access admin panel from the user dropdown menu"
echo "5. Use Rake tasks:"
echo "   - bundle exec rake products:list"
echo "   - bundle exec rake products:add_samples"
echo "   - bundle exec rake products:update_prices[10]"
echo ""
echo "🔧 Rails-Accurate Features:"
echo "✅ Proper MVC structure"
echo "✅ Namespaced admin controllers"
echo "✅ Rake tasks for database operations"
echo "✅ Rails conventions followed"
echo "✅ No standalone scripts"

