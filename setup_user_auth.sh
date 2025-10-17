#!/bin/bash

# Setup script for User Authentication feature
echo "🔐 Setting up User Authentication feature..."

# Run the new migration
echo "📊 Running user migration..."
bundle exec rails db:migrate

# Run tests to make sure everything works
echo "🧪 Running tests..."
bundle exec rspec spec/models/user_spec.rb
bundle exec rspec spec/controllers/authentication_controller_spec.rb

# Run code quality checks
echo "🔍 Running code quality checks..."
bundle exec rubocop app/models/user.rb app/controllers/authentication_controller.rb

echo "✅ User Authentication feature setup complete!"
echo ""
echo "🎯 New Features Added:"
echo "  - User registration and login"
echo "  - User dashboard with order history"
echo "  - Protected routes and authentication"
echo "  - User profile management"
echo "  - Comprehensive test coverage"
echo ""
echo "🚀 Next Steps:"
echo "1. Test the feature locally"
echo "2. Create a feature branch: git checkout -b feature/user-authentication"
echo "3. Commit your changes: git add . && git commit -m 'feat: add user authentication system'"
echo "4. Push to GitHub: git push origin feature/user-authentication"
echo "5. Create a pull request to test the CI/CD pipeline"
echo ""
echo "📱 Test the feature:"
echo "  - Visit http://localhost:3000/register to create an account"
echo "  - Visit http://localhost:3000/login to sign in"
echo "  - Visit http://localhost:3000/dashboard to see user dashboard"
