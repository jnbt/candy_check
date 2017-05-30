# coding: utf-8
# frozen_string_literal: true
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'candy_check/version'

Gem::Specification.new do |spec|
  spec.name          = 'candy_check'
  spec.version       = CandyCheck::VERSION
  spec.authors       = ['Jonas Thiel']
  spec.email         = ['jonas@thiel.io']
  spec.summary       = 'Check and verify in-app receipts'
  spec.homepage      = 'https://github.com/jnbt/candy_check'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.required_ruby_version = Gem::Requirement.new('>= 2.0')

  spec.add_dependency 'multi_json',        '~> 1.10'
  spec.add_dependency 'google-api-client', '~> 0.8.6'
  spec.add_dependency 'thor',              '~> 0.19'

  spec.add_development_dependency 'rubocop',         '~> 0.41'
  spec.add_development_dependency 'inch',            '~> 0.5'
  spec.add_development_dependency 'bundler',         '~> 1.7'
  spec.add_development_dependency 'rake',            '~> 11.1'
  spec.add_development_dependency 'coveralls',       '~> 0.8'
  spec.add_development_dependency 'minitest',        '~> 5.9'
  spec.add_development_dependency 'minitest-around', '~> 0.3'
  spec.add_development_dependency 'webmock',         '~> 2.1'
end
