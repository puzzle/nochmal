# frozen_string_literal: true

source "https://rubygems.org"

# Specify your gem's dependencies in nochmal.gemspec
gemspec

gem "rubocop-performance", require: false
gem "rubocop-rspec", require: false

group :test do
  gem "tzinfo-data", platforms: %i[mingw mswin x64_mingw jruby]
end

group :development, :test do
  gem "pry", "~> 0.14.1"
  gem "pry-byebug", "~> 3.8"
end
