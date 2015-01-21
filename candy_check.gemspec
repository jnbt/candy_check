# coding: utf-8
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
  spec.executables   = spec.files.grep(/^bin\//) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(/^(test|spec|features)\//)
  spec.require_paths = ['lib']

  spec.add_dependency 'multi_json',        '~> 1.10'
  spec.add_dependency 'google-api-client', '~> 0.8'
  spec.add_dependency 'thor',              '~> 0.19'

  spec.add_development_dependency 'rubocop',         '~> 0.28'
  spec.add_development_dependency 'inch',            '~> 0.5'
  spec.add_development_dependency 'bundler',         '~> 1.7'
  spec.add_development_dependency 'rake',            '~> 10.0'
  spec.add_development_dependency 'coveralls',       '~> 0.7'
  spec.add_development_dependency 'minitest',        '~> 5.5'
  spec.add_development_dependency 'minitest-around', '~> 0.3'
  spec.add_development_dependency 'webmock',         '~> 1.20'
end
