# Use Ruby 3.0 as base image (more compatible than 2.6.10)
FROM ruby:3.0-slim

# Install system dependencies
RUN apt-get update -qq && apt-get install -y \
    build-essential \
    libpq-dev \
    curl \
    git \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy Gemfile and Gemfile.lock
COPY Gemfile Gemfile.lock ./

# Install gems
RUN bundle config set --local deployment 'true' && \
    bundle config set --local without 'development test' && \
    bundle install

# Copy application code
COPY . .

# Create a non-root user
RUN useradd -m -u 1000 rails && chown -R rails:rails /app
USER rails

# Expose port
EXPOSE 3000

# Set environment variables
ENV RAILS_ENV=production
ENV RAILS_SERVE_STATIC_FILES=true
ENV RAILS_LOG_TO_STDOUT=true

# Precompile assets
RUN bundle exec rails assets:precompile

# Start the server
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0", "-p", "3000"]
