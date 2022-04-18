# frozen_string_literal: true

require_relative "lib/nochmal/version"

Gem::Specification.new do |spec|
  spec.name          = "nochmal"
  spec.version       = Nochmal::VERSION
  spec.authors       = ["Thomas Burkhalter"]
  spec.email         = ["new.mysteryman@gmail.com"]

  spec.summary       = "Handles ActiveStorage attachment reuploading."
  spec.description   = "Adds a rake task to reupload ActiveStorage attachments to a new storage."
  spec.homepage      = "https://github.com/puzzle/nochmal"
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.5.0")

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "https://github.com/puzzle/nochmal/blob/main/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{\A(?:test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"

  spec.add_dependency "pastel" # terminal colors

  spec.add_development_dependency "codecov"
  spec.add_development_dependency "dotenv"
  spec.add_development_dependency "rails"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "rspec-its"
  spec.add_development_dependency "rspec-rails"
  spec.add_development_dependency "rspec-rake"
  spec.add_development_dependency "rubocop", "~> 1.7"
  spec.add_development_dependency "rubocop-discourse", "~> 2.4"
  spec.add_development_dependency "rubocop-performance", "~> 1.6"
  spec.add_development_dependency "rubocop-rspec", "~> 2.5.0"
  spec.add_development_dependency "simplecov"
  spec.add_development_dependency "sqlite3"

  # For more information and examples about making a new gem, checkout our
  # guide at: https://bundler.io/guides/creating_gem.html
end
