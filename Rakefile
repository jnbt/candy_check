require 'bundler/gem_tasks'
require 'rake/testtask'
require 'rubocop/rake_task'

RUBOCOP_INCOMPATIBLE_VERSIONS = %i(jruby-1.7.26)

Rake::TestTask.new(:spec) do |test|
  test.test_files = FileList['spec/**/*_spec.rb']
  test.libs << 'spec'
  test.verbose = true
end

RuboCop::RakeTask.new

deault_task = %i(spec)

deault_task << 'rubocop' if RUBOCOP_INCOMPATIBLE_VERSIONS.include? RUBY_VERSION
task default: deault_task
