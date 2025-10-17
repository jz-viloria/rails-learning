# 🚀 CI/CD Pipeline Guide

This guide explains the GitHub Actions CI/CD pipeline setup for the Rails Dropshipping Store.

## 📋 Overview

Our CI/CD pipeline includes:
- **Code Quality Checks** (RuboCop, Brakeman, Bundle Audit)
- **Automated Testing** (RSpec, System Tests)
- **Security Scanning** (Vulnerability checks)
- **Build Verification** (Asset compilation)
- **Deployment** (Staging & Production)
- **Pull Request Validation**

## 🔄 Pipeline Workflow

### 1. **Code Quality Job** (`code-quality`)
**Triggers**: Push to main/develop, Pull Requests

**Checks:**
- ✅ **RuboCop** - Code style and formatting
- ✅ **Brakeman** - Security vulnerability scanning
- ✅ **Bundle Audit** - Gem vulnerability checking

**Outputs:**
- Code quality reports
- Security scan results

### 2. **Testing Job** (`test`)
**Triggers**: Push to main/develop, Pull Requests

**Setup:**
- PostgreSQL database service
- Ruby 2.6.10 environment
- Node.js 16 for asset compilation

**Tests:**
- ✅ **RSpec** - Unit and integration tests
- ✅ **System Tests** - End-to-end testing
- ✅ **Database Tests** - Model and controller tests

**Outputs:**
- Test results and coverage reports

### 3. **Build Job** (`build`)
**Triggers**: After code-quality and test jobs pass

**Process:**
- ✅ **Asset Precompilation** - Production asset build
- ✅ **Security Scan** - Final security check
- ✅ **Build Verification** - Ensure app builds correctly

**Outputs:**
- Compiled assets
- Security reports

### 4. **Deployment Jobs**

#### **Staging Deployment** (`deploy-staging`)
**Triggers**: Push to `develop` branch
**Environment**: `staging`

#### **Production Deployment** (`deploy-production`)
**Triggers**: Push to `main` branch
**Environment**: `production`

## 🛡️ Branch Protection Rules

### Main Branch Protection
```yaml
Required Status Checks:
  - code-quality
  - test
  - build

Required Reviews: 1
Dismiss Stale Reviews: true
Require Up-to-date Branches: true
Require Linear History: true
```

### Pull Request Requirements
- ✅ All CI checks must pass
- ✅ At least 1 code review approval
- ✅ No merge conflicts
- ✅ Up-to-date with main branch

## 🧪 Testing Framework

### RSpec Configuration
```ruby
# spec/rails_helper.rb
RSpec.configure do |config|
  config.use_transactional_fixtures = true
  config.include FactoryBot::Syntax::Methods
end
```

### Test Structure
```
spec/
├── models/           # Model tests
├── controllers/      # Controller tests
├── factories/        # Test data factories
├── support/          # Test helpers
└── system/           # System tests
```

### Running Tests Locally
```bash
# Run all tests
bundle exec rspec

# Run specific test file
bundle exec rspec spec/models/product_spec.rb

# Run with coverage
COVERAGE=true bundle exec rspec

# Run system tests
bundle exec rails test:system
```

## 🔍 Code Quality Tools

### RuboCop Configuration
```yaml
# .rubocop.yml
AllCops:
  TargetRubyVersion: 2.6
  NewCops: enable

Style/StringLiterals:
  EnforcedStyle: single_quotes

Layout/LineLength:
  Max: 120
```

### Running Code Quality Checks
```bash
# Run RuboCop
bundle exec rubocop

# Auto-fix issues
bundle exec rubocop -a

# Run Brakeman security scan
bundle exec brakeman

# Run bundle audit
bundle exec bundle-audit check --update
```

## 🚀 Deployment Process

### Staging Deployment
1. **Trigger**: Push to `develop` branch
2. **Process**: 
   - Run all CI checks
   - Deploy to staging environment
   - Run smoke tests
3. **Notification**: Team notification on success/failure

### Production Deployment
1. **Trigger**: Push to `main` branch
2. **Process**:
   - Run all CI checks
   - Deploy to production environment
   - Run health checks
3. **Notification**: Team notification on success/failure

## 📊 Monitoring & Alerts

### Pipeline Monitoring
- **Success Rate**: Track pipeline success percentage
- **Build Time**: Monitor build duration
- **Failure Analysis**: Identify common failure patterns

### Quality Metrics
- **Test Coverage**: Maintain >80% coverage
- **Code Quality**: RuboCop violations count
- **Security**: Vulnerability count and severity

### Alerts
- **Pipeline Failures**: Immediate notification
- **Security Issues**: High-priority alerts
- **Deployment Issues**: Production deployment alerts

## 🛠️ Local Development Setup

### Prerequisites
```bash
# Install dependencies
bundle install

# Set up database
rails db:create
rails db:migrate
rails db:seed

# Install pre-commit hooks (optional)
bundle exec overcommit --install
```

### Development Workflow
```bash
# 1. Create feature branch
git checkout -b feature/new-feature

# 2. Make changes and test locally
bundle exec rspec
bundle exec rubocop

# 3. Commit with conventional format
git commit -m "feat: add new feature"

# 4. Push and create PR
git push origin feature/new-feature

# 5. Wait for CI checks to pass
# 6. Get code review approval
# 7. Merge to main
```

## 🔧 Troubleshooting

### Common Issues

#### **CI Pipeline Fails**
```bash
# Check logs in GitHub Actions
# Fix issues locally first
bundle exec rspec
bundle exec rubocop
```

#### **Test Failures**
```bash
# Run specific failing test
bundle exec rspec spec/models/product_spec.rb:25

# Check database setup
rails db:test:prepare
```

#### **Code Quality Issues**
```bash
# Auto-fix RuboCop issues
bundle exec rubocop -a

# Check specific file
bundle exec rubocop app/models/product.rb
```

#### **Security Issues**
```bash
# Update vulnerable gems
bundle update

# Check specific vulnerability
bundle exec bundle-audit check
```

## 📈 Best Practices

### Development
- ✅ Write tests for new features
- ✅ Keep commits small and focused
- ✅ Use conventional commit messages
- ✅ Run quality checks before pushing

### Code Review
- ✅ Review code, not the person
- ✅ Be constructive and specific
- ✅ Check for security issues
- ✅ Verify test coverage

### Deployment
- ✅ Deploy frequently in small increments
- ✅ Monitor application after deployment
- ✅ Have rollback plan ready
- ✅ Document any manual steps

## 🎯 Next Steps

### Potential Improvements
1. **Performance Testing** - Add performance benchmarks
2. **Integration Testing** - Add API integration tests
3. **Load Testing** - Add load testing for production
4. **Monitoring** - Add application performance monitoring
5. **Automated Rollback** - Add automatic rollback on failures

### Advanced Features
1. **Feature Flags** - Add feature flag management
2. **Blue-Green Deployment** - Implement zero-downtime deployments
3. **Canary Releases** - Gradual rollout of new features
4. **A/B Testing** - Automated A/B testing framework

---

## 📚 Resources

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [RSpec Documentation](https://rspec.info/)
- [RuboCop Documentation](https://rubocop.org/)
- [Rails Testing Guide](https://guides.rubyonrails.org/testing.html)
- [Conventional Commits](https://www.conventionalcommits.org/)

---

*This CI/CD pipeline ensures code quality, security, and reliable deployments for the Rails Dropshipping Store.* 🚀
