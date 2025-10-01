# frozen_string_literal: true

source "https://rubygems.org"

gem "hanami", "~> 2.2"
gem "hanami-sprockets", path: "/Users/andrew/code/hanami-sprockets"
gem "hanami-controller", "~> 2.2"
gem "hanami-db", "~> 2.2"
gem "hanami-router", "~> 2.2"
gem "hanami-validations", "~> 2.2"
gem "hanami-view", "~> 2.2"

gem "dry-types", "~> 1.7"
gem "dry-operation"
gem "puma"
gem "rake"
gem "pg"
gem "pagy"
gem "rack-cors"
gem "faraday"
gem "faraday-retry"
gem "faraday-follow_redirects"
gem "semantic"
gem "semantic_range"
gem "purl"
gem "irb"
gem "bootstrap", "~> 5.3"
gem "sassc"

group :development do
  gem "hanami-webconsole", "~> 2.2"
end

group :development, :test do
  gem "dotenv"
end

group :cli, :development do
  gem "hanami-reloader", "~> 2.2"
end

group :cli, :development, :test do
  gem "hanami-rspec", "~> 2.2"
end

group :test do
  # Database
  gem "database_cleaner-sequel"

  # Web integration
  gem "capybara"
  gem "rack-test"
end
