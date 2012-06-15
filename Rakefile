require 'rubygems'
begin
  require 'bundler/setup'
rescue LoadError
  puts 'You must `gem install bundler` and `bundle install` to run rake tasks'
end

require 'rake'
Bundler::GemHelper.install_tasks

desc 'Default: run unit tests'
task :default => :test

require 'rspec'
require 'rspec/core/rake_task'
desc 'Run the unit tests'
RSpec::Core::RakeTask.new(:test)
