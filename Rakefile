require 'rubygems'
require 'rake'

desc 'Default: run unit tests'
task :default => :test

begin
  require 'rspec'
  require 'rspec/core/rake_task'
  desc 'Run the unit tests'
  RSpec::Core::RakeTask.new(:test)
rescue LoadError
  task :test do
    raise "You must have rspec 2.0 installed to run the tests"
  end
end

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "tribune-is_it_working"
    gem.summary = %Q{Rack handler for monitoring several parts of a web application.}
    gem.description = %Q{Rack handler for monitoring several parts of a web application so one request can determine which system or dependencies are down.}
    gem.authors = ["Brian Durand"]
    gem.email = ["bdurand@tribune.com"]
    gem.files = FileList["lib/**/*", "spec/**/*", "bin/**/*", "example/**/*" "README.rdoc", "Rakefile", "TRIBUNE_CODE"].to_a
    gem.has_rdoc = true
    gem.rdoc_options << '--line-numbers' << '--inline-source' << '--main' << 'README.rdoc'
    gem.extra_rdoc_files = ["README.rdoc"]
    # Add dependencies with gem.add_dependency('gem_name')
    gem.add_development_dependency('rspec', '>= 2.0')
    gem.add_development_dependency('webmock', '>= 1.6.0')
    gem.add_development_dependency('memcache-client')
    gem.add_development_dependency('dalli')
  end
rescue LoadError
end
