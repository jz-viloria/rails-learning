source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "2.6.10"

# Use Rails 6.0 which is compatible with Ruby 2.6
gem "rails", "~> 6.0.0"

# Use postgresql as the database for Active Record
gem "pg", "~> 1.1"

# Use the Puma web server
gem "puma", "~> 4.3"

# Build JSON APIs with ease
gem "jbuilder"

# Use Redis adapter to run Action Cable in production
gem "redis", "~> 4.0"

# Use Active Model has_secure_password
gem "bcrypt", "~> 3.1.7"

# Logger for Rails 6.0 compatibility
gem "logger"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[ mswin mswin64 mingw x64_mingw jruby ]

group :development, :test do
  # Static analysis for security vulnerabilities
  gem "brakeman", require: false
end

group :development do
  # Use console on exceptions pages
  gem "web-console"
end