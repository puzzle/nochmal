# frozen_string_literal: true

source "https://rubygems.org"

# Specify your gem's dependencies in nochmal.gemspec
gemspec

gem "rake", "~> 13.0"
gem "rspec", "~> 3.0"
gem "rubocop", "~> 1.7"

group :test do
  gem "tzinfo-data", platforms: %i[mingw mswin x64_mingw jruby]
end

group :development, :test do
  gem "pry", "~> 0.14.1"
  gem "pry-byebug", "~> 3.8"
end
