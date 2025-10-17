#!/bin/bash

# Setup script for CI/CD pipeline
echo "🚀 Setting up CI/CD pipeline for Rails Dropshipping Store..."

# Install new gems
echo "📦 Installing new gems..."
bundle install

# Set up RSpec
echo "🧪 Setting up RSpec..."
bundle exec rails generate rspec:install

# Set up FactoryBot
echo "🏭 Setting up FactoryBot..."
bundle exec rails generate factory_bot:install

# Set up test database
echo "🗄️ Setting up test database..."
RAILS_ENV=test bundle exec rails db:create
RAILS_ENV=test bundle exec rails db:schema:load
RAILS_ENV=test bundle exec rails db:seed

# Run initial tests
echo "🧪 Running initial tests..."
bundle exec rspec

# Run code quality checks
echo "🔍 Running code quality checks..."
bundle exec rubocop
bundle exec brakeman
bundle exec bundle-audit check --update

echo "✅ CI/CD pipeline setup complete!"
echo ""
echo "📚 Next steps:"
echo "1. Push your code to GitHub"
echo "2. Set up branch protection rules in GitHub"
echo "3. Create a pull request to test the pipeline"
echo "4. Review the CI_CD_GUIDE.md for detailed instructions"
echo ""
echo "🎯 Your Rails app now has professional CI/CD practices!"
