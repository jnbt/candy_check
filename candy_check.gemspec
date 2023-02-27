# coding: utf-8

lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "candy_check/version"

Gem::Specification.new do |spec|
  spec.name = "candy_check"
  spec.version = CandyCheck::VERSION
  spec.authors = ["Jonas Thiel", "Christoph Weegen"]
  spec.email = ["jonas@thiel.io"]
  spec.summary = "Check and verify in-app receipts"
  spec.homepage = "https://github.com/jnbt/candy_check"
  spec.license = "MIT"

  spec.files = `git ls-files -z`.split("\x0")
  spec.executables = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.required_ruby_version = Gem::Requirement.new(">= 2.6")

  spec.add_dependency "google-apis-androidpublisher_v3", "~> 0.34.0"
  spec.add_dependency "googleauth", "~> 1.3.0"
  spec.add_dependency "multi_json", "~> 1.15"
  spec.add_dependency "thor", "< 2.0"

  spec.add_development_dependency "awesome_print"
  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "guard"
  spec.add_development_dependency "guard-minitest"
  spec.add_development_dependency "inch", "~> 0.7"
  spec.add_development_dependency "minitest", "~> 5.10"
  spec.add_development_dependency "minitest-around", "~> 0.4"
  spec.add_development_dependency "minitest-focus"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rubocop", "~> 1.46"
  spec.add_development_dependency "simplecov", "~> 0.18.0"
  spec.add_development_dependency "simplecov-lcov", "~> 0.8.0"
  spec.add_development_dependency "timecop", "~> 0.9"
  spec.add_development_dependency "vcr", "~> 6.1"
  spec.add_development_dependency "webmock", "~> 3.0"
end
