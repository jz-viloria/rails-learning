# Rails Dropshipping Store

A comprehensive Ruby on Rails application demonstrating modern web development practices with a complete CI/CD pipeline.

## 🚀 Features

### Core Functionality
- **Product Catalog** - Browse and view products with detailed information
- **Shopping Cart** - Add/remove items with persistent session storage
- **User Authentication** - Secure registration, login, and session management
- **User Dashboard** - Personal profile with order history and statistics
- **Order Management** - Complete order processing system

### Technical Features
- **Rails 6.0** - Modern Ruby on Rails framework
- **PostgreSQL** - Robust database with proper relationships
- **Bootstrap 5** - Responsive, modern UI design
- **RSpec Testing** - Comprehensive test coverage
- **CI/CD Pipeline** - Automated testing and deployment with GitHub Actions

## 🛠️ Tech Stack

- **Backend**: Ruby on Rails 6.0
- **Database**: PostgreSQL 14
- **Frontend**: Bootstrap 5, HTML5, CSS3
- **Testing**: RSpec, FactoryBot, Capybara
- **Code Quality**: RuboCop, Brakeman, Bundle Audit
- **CI/CD**: GitHub Actions
- **Server**: WEBrick (development)

## 📋 Prerequisites

- Ruby 2.6.10
- PostgreSQL 14
- Bundler
- Git

## 🚀 Getting Started

### 1. Clone the Repository
```bash
git clone https://github.com/jz-viloria/rails-learning.git
cd rails-learning
```

### 2. Install Dependencies
```bash
bundle install --path vendor/bundle
```

### 3. Database Setup
```bash
# Create PostgreSQL user (if needed)
createuser -s postgres

# Create databases
createdb dropshipping_store_development
createdb dropshipping_store_test

# Run migrations
bundle exec rails db:migrate

# Seed sample data
bundle exec rails db:seed
```

### 4. Start the Server
```bash
bundle exec ruby start_server.rb
```

Visit `http://localhost:3000` to see the application.

## 🧪 Testing

### Run All Tests
```bash
bundle exec rspec
```

### Run Specific Test Suites
```bash
# Model tests
bundle exec rspec spec/models/

# Controller tests
bundle exec rspec spec/controllers/

# Run with coverage
COVERAGE=true bundle exec rspec
```

### Code Quality Checks
```bash
# Code style
bundle exec rubocop

# Security scan
bundle exec brakeman

# Dependency audit
bundle exec bundle-audit check --update
```

## 📁 Project Structure

```
rails-learning/
├── app/                    # Application code
│   ├── controllers/        # Request handlers
│   ├── models/            # Data models and business logic
│   ├── views/             # HTML templates
│   └── helpers/           # View helpers
├── config/                # Configuration files
│   ├── routes.rb          # URL routing
│   ├── database.yml       # Database configuration
│   └── application.rb     # App configuration
├── db/                    # Database files
│   ├── migrate/           # Database migrations
│   └── seeds.rb           # Sample data
├── spec/                  # Test files
│   ├── models/            # Model tests
│   ├── controllers/       # Controller tests
│   └── factories/         # Test data factories
├── .github/workflows/     # CI/CD pipelines
└── README.md              # This file
```

## 🔐 Authentication

The application includes a complete user authentication system:

- **Registration**: Users can create accounts with email/password
- **Login/Logout**: Secure session management
- **Dashboard**: Personal user area with order history
- **Protected Routes**: Access control for user-specific pages

### User Model Features
- Secure password hashing with `has_secure_password`
- Email validation and uniqueness
- Optional shipping address storage
- Admin user support
- Order history tracking

## 🛒 Shopping Cart

The shopping cart system provides:

- **Session-based Storage**: Cart persists across browser sessions
- **Add/Remove Items**: Easy product management
- **Quantity Updates**: Adjust item quantities
- **Cart Total**: Automatic price calculations
- **Guest Support**: Works without user registration

## 🚀 CI/CD Pipeline

The project includes a comprehensive GitHub Actions pipeline:

### Code Quality Checks
- **RuboCop**: Code style and formatting
- **Brakeman**: Security vulnerability scanning
- **Bundle Audit**: Gem vulnerability checking

### Testing
- **RSpec**: Unit and integration tests
- **FactoryBot**: Test data generation
- **Database Testing**: Isolated test database

### Deployment
- **Staging**: Automatic deployment on `develop` branch
- **Production**: Automatic deployment on `main` branch
- **Health Checks**: Post-deployment verification

## 📊 Database Schema

### Users Table
- `id`, `first_name`, `last_name`, `email`
- `password_digest` (encrypted)
- `address_line1`, `address_line2`, `city`, `state`, `zip_code`, `country`
- `preferences` (JSON), `admin` (boolean)
- `created_at`, `updated_at`

### Products Table
- `id`, `name`, `description`, `price`, `image_url`
- `created_at`, `updated_at`

### Orders Table
- `id`, `user_id` (optional for guests)
- `status`, `total_amount`
- `created_at`, `updated_at`

### Order Items Table
- `id`, `order_id`, `product_id`, `quantity`, `price`
- `created_at`, `updated_at`

## 🔧 Development

### Adding New Features
1. Create a feature branch: `git checkout -b feature/new-feature`
2. Make your changes
3. Add tests for new functionality
4. Run the test suite: `bundle exec rspec`
5. Check code quality: `bundle exec rubocop`
6. Commit and push your changes
7. Create a pull request

### Code Style Guidelines
- Follow Ruby style guide (enforced by RuboCop)
- Write tests for all new functionality
- Use meaningful commit messages
- Keep methods small and focused
- Add comments for complex logic

## 🐛 Troubleshooting

### Common Issues

**Database Connection Error**
```bash
# Ensure PostgreSQL is running
brew services start postgresql@14

# Create the postgres user if needed
createuser -s postgres
```

**Bundle Install Issues**
```bash
# Clear bundle cache
bundle clean --force

# Reinstall gems
bundle install --path vendor/bundle
```

**Test Failures**
```bash
# Reset test database
bundle exec rails db:test:prepare

# Run specific test
bundle exec rspec spec/models/user_spec.rb
```

## 📝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests
5. Ensure all tests pass
6. Submit a pull request

## 📄 License

This project is for educational purposes and demonstrates Rails development best practices.

## 🙏 Acknowledgments

- Ruby on Rails community for excellent documentation
- Bootstrap team for the UI framework
- RSpec team for the testing framework
- GitHub Actions for CI/CD capabilities
