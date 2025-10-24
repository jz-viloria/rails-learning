# Use Ruby 2.6.10 as base image to match our application
FROM ruby:2.6.10-slim

# Install system dependencies
RUN apt-get update -qq && apt-get install -y \
    build-essential \
    libpq-dev \
    postgresql-client \
    curl \
    git \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy Gemfile and Gemfile.lock
COPY Gemfile Gemfile.lock ./

# Install the correct bundler version first
RUN gem install bundler:1.17.2

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

# Skip asset precompilation due to Logger compatibility issues
# RUN bundle exec rails assets:precompile

# Start the server using our custom script
CMD ["bundle", "exec", "ruby", "start_server.rb"]
