# frozen_string_literal: true

require_relative "lib/zoho_sign/version"

Gem::Specification.new do |spec|
  spec.name = "zoho_sign"
  spec.version = ZohoSign::VERSION
  spec.authors = ["Wecasa Developers Team", "Mohamed Ziata"]
  spec.email = ["tech@wecasa.fr", "wakematta@gmail.com"]

  spec.summary = "Zoho Sign API Wrapper"
  spec.description = "Ruby gem to allow easy interaction with Zoho Sign API (v1)."
  spec.homepage = "https://www.zoho.com/sign/api"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.6.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["documentation_uri"] = "https://github.com/wecasa/zoho_sign"
  spec.metadata["source_code_uri"] = "https://github.com/wecasa/zoho_sign"
  spec.metadata["changelog_uri"] = "https://github.com/wecasa/zoho_sign/blob/master/CHANGELOG.md"
  spec.metadata["bug_tracker_uri"] = "https://github.com/wecasa/zoho_sign/issues"
  spec.metadata["bug_tracker_uri"] = "https://github.com/wecasa/zoho_sign/issues"
  spec.metadata["rubygems_mfa_required"] = "true"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  spec.add_dependency "activesupport"
  spec.add_dependency "addressable"
  spec.add_dependency "dry-configurable", "~> 0.13"
  spec.add_dependency "faraday"
  spec.add_dependency "faraday_middleware"
  spec.add_dependency "rainbow"

  # For more information and examples about making a new gem, checkout our
  # guide at: https://bundler.io/guides/creating_gem.html
end
