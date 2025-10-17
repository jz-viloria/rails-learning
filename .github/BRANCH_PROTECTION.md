# Branch Protection Rules

This document outlines the recommended branch protection rules for this Rails application.

## Main Branch Protection

### Required Status Checks
- ✅ **Code Quality Checks** - RuboCop, Brakeman, Bundle Audit
- ✅ **Test Suite** - RSpec tests must pass
- ✅ **Build** - Application must build successfully
- ✅ **Security Scan** - No security vulnerabilities

### Required Reviews
- ✅ **Require pull request reviews before merging**
- ✅ **Required number of reviewers: 1**
- ✅ **Dismiss stale reviews when new commits are pushed**
- ✅ **Require review from code owners**

### Branch Protection Settings
- ✅ **Require branches to be up to date before merging**
- ✅ **Require linear history**
- ✅ **Include administrators**
- ✅ **Restrict pushes that create files larger than 100MB**

## Development Workflow

### Branch Naming Convention
- `feature/description` - New features
- `fix/description` - Bug fixes
- `hotfix/description` - Critical production fixes
- `refactor/description` - Code refactoring
- `docs/description` - Documentation updates

### Commit Message Format
Follow [Conventional Commits](https://www.conventionalcommits.org/):

```
type(scope): description

[optional body]

[optional footer(s)]
```

**Types:**
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting, etc.)
- `refactor`: Code refactoring
- `test`: Adding or updating tests
- `chore`: Maintenance tasks

**Examples:**
```
feat(cart): add shopping cart functionality
fix(products): resolve price calculation bug
docs(readme): update installation instructions
```

### Pull Request Requirements

#### Title Format
- Use conventional commit format
- Be descriptive and concise
- Include issue number if applicable

#### Description Template
```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update

## Testing
- [ ] Unit tests added/updated
- [ ] Integration tests added/updated
- [ ] Manual testing completed

## Checklist
- [ ] Code follows style guidelines
- [ ] Self-review completed
- [ ] Documentation updated
- [ ] No breaking changes (or documented)
```

## Code Review Guidelines

### For Reviewers
1. **Check Code Quality**
   - Follows Ruby/Rails conventions
   - No security vulnerabilities
   - Proper error handling
   - Good test coverage

2. **Check Functionality**
   - Meets requirements
   - Handles edge cases
   - Performance considerations
   - User experience

3. **Check Documentation**
   - Code is self-documenting
   - Comments where necessary
   - README updates if needed

### For Authors
1. **Before Submitting PR**
   - Run tests locally
   - Check code style with RuboCop
   - Update documentation
   - Test manually

2. **Respond to Feedback**
   - Address all comments
   - Ask questions if unclear
   - Update tests if needed

## Automated Checks

### Pre-commit Hooks (Recommended)
```bash
# Install pre-commit hooks
bundle exec overcommit --install

# Run checks before commit
bundle exec overcommit --run
```

### Manual Checks
```bash
# Run all tests
bundle exec rspec

# Check code style
bundle exec rubocop

# Security scan
bundle exec brakeman

# Bundle audit
bundle exec bundle-audit check --update
```

## Emergency Procedures

### Hotfix Process
1. Create hotfix branch from main
2. Make minimal necessary changes
3. Add tests for the fix
4. Get expedited review
5. Merge to main
6. Deploy immediately
7. Create follow-up PR for any additional improvements

### Rollback Process
1. Identify the problematic commit
2. Create rollback PR
3. Get approval from team lead
4. Deploy rollback
5. Investigate and fix original issue

## Monitoring and Alerts

### CI/CD Pipeline Status
- Monitor pipeline success rates
- Set up alerts for failures
- Track deployment frequency

### Code Quality Metrics
- Test coverage percentage
- Code complexity scores
- Security vulnerability count
- Technical debt indicators

## Best Practices

### Development
- Keep branches small and focused
- Commit frequently with meaningful messages
- Write tests for new features
- Update documentation

### Code Review
- Be constructive and respectful
- Focus on code, not the person
- Suggest improvements, don't just point out problems
- Approve when ready, don't delay unnecessarily

### Deployment
- Deploy frequently in small increments
- Monitor application after deployment
- Have rollback plan ready
- Document any manual steps
