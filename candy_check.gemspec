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

  spec.required_ruby_version = Gem::Requirement.new(">= 2.4")

  spec.add_dependency "google-api-client", "~> 0.34.0"
  spec.add_dependency "multi_json", "~> 1.10"
  spec.add_dependency "thor", "~> 0.19"

  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "coveralls", "~> 0.8"
  spec.add_development_dependency "inch", "~> 0.7"
  spec.add_development_dependency "minitest", "~> 5.10"
  spec.add_development_dependency "minitest-around", "~> 0.4"
  spec.add_development_dependency "minitest-focus"
  spec.add_development_dependency "rake", "~> 12.0"
  spec.add_development_dependency "rubocop", "~> 0.48"
  spec.add_development_dependency "timecop", "~> 0.8"
  spec.add_development_dependency "webmock", "~> 3.0"
  spec.add_development_dependency "vcr"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "awesome_print"
  spec.add_development_dependency "guard"
  spec.add_development_dependency "guard-minitest"
end
